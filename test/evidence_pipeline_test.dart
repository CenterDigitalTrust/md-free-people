import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mdfp_app/core/storage/local_store.dart';
import 'package:mdfp_app/core/queue/sync_queue_manager.dart';
import 'package:mdfp_app/core/capture/evidence_verifier.dart';

/// In-memory queue fixture isolates HTTP behavior from platform plugins.
class MemoryStore extends LocalEvidenceStore {
  final List<EvidenceItem> items;
  MemoryStore(this.items);
  @override
  Future<List<EvidenceItem>> getAllItems() async => items;
  @override
  Future<void> updateItem(EvidenceItem item) async {
    // Objects are shared by this test fixture.
  }
}

EvidenceItem fixture(String id,
    {String status = 'local', String path = 'test.jpg'}) {
  // Model an immutable signed record with a deterministic digest.
  final bytes = utf8.encode('real file bytes');
  final hash = sha256.convert(bytes).toString();
  final canonical = jsonEncode({
    'device_id': 'registered-device',
    'file_sha256': hash,
    'file_size': bytes.length
  });
  return EvidenceItem(
      localId: id,
      mediaType: 'image/jpeg',
      filePath: path,
      fileSha256: hash,
      fileSize: bytes.length,
      canonicalJson: canonical,
      recordDigest: sha256.convert(utf8.encode(canonical)).toString(),
      signature: base64Encode([1, 2, 3]),
      createdAtMs: 1,
      status: status);
}

void main() {
  // Test retries, real server response shape, persistence, and byte tampering.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'mdfp_device_id': 'registered-device',
      'file_upload_policy': 'manual'
    });
  });

  test(
      'accepted record reads transaction and numeric block time from receipt.anchor',
      () async {
    final item = fixture('one');
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        expect(request.url.path, '/v1/records');
        return http.Response(
            jsonEncode({'short_id': 'abc123', 'record_token': 'token'}), 202);
      }
      return http.Response(
          jsonEncode({
            'status': 'anchored',
            'receipt': {
              'anchor': {
                'tx_signature': 'real-tx',
                'block_time': 1700000000,
              }
            }
          }),
          200);
    });
    await SyncQueueManager(store: MemoryStore([item]), httpClient: client)
        .processQueue();
    expect(item.status, 'anchored');
    expect(item.solanaTx, 'real-tx');
    expect(item.blockTime, '2023-11-14T22:13:20.000Z');
  });

  test('rate limit preserves evidence for retry without inventing acceptance',
      () async {
    final item = fixture('limited');
    await SyncQueueManager(
            store: MemoryStore([item]),
            httpClient: MockClient((_) async => http.Response('{}', 429)))
        .processQueue();
    expect(item.status, 'failed');
    expect(item.shortId, isNull);
    expect(item.canonicalJson, fixture('limited').canonicalJson);
  });

  test('malformed server JSON remains retryable', () async {
    final item = fixture('bad-json');
    await SyncQueueManager(
            store: MemoryStore([item]),
            httpClient: MockClient((_) async => http.Response('not-json', 202)))
        .processQueue();
    expect(item.status, 'failed');
    expect(item.shortId, isNull);
  });

  test('anchored files remain eligible for delayed Vault upload', () async {
    final item = fixture('late', status: 'anchored')..shortId = 'id';
    final store = MemoryStore([item]);
    expect(await store.getPendingQueue(), [item]);
  });

  test('local verification detects actual changed bytes', () async {
    final dir = await Directory.systemTemp.createTemp('mdfp-integrity-');
    try {
      final file = File('${dir.path}/evidence.jpg');
      await file.writeAsString('real file bytes');
      final item = fixture('integrity', path: file.path);
      expect(await EvidenceVerifier.verifyLocal(item), isTrue);
      await file.writeAsString('fake file bytes');
      expect(await EvidenceVerifier.verifyLocal(item), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test(
      'concurrent saves preserve records; stale updates cannot regress accepted state',
      () async {
    final dir = await Directory.systemTemp.createTemp('mdfp-store-');
    try {
      await File('${dir.path}/mdfp_evidence_index.json').writeAsString('[]');
      final store = LocalEvidenceStore(directory: dir);
      await Future.wait(
          List.generate(12, (i) => store.saveItem(fixture('item-$i'))));
      expect((await store.getAllItems()).length, 12);
      final accepted = fixture('item-0', status: 'anchored')
        ..vaultStatus = 'uploaded';
      await store.updateItem(accepted);
      await store.updateItem(fixture('item-0', status: 'failed'));
      final saved = await store.getItemByLocalId('item-0');
      expect(saved!.status, 'anchored');
      expect(saved.vaultStatus, 'uploaded');
      await store.updateItem(fixture('purged-record'));
      expect((await store.getAllItems()).length, 12);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('separate worker isolates preserve every concurrent write', () async {
    final dir = await Directory.systemTemp.createTemp('mdfp-isolates-');
    try {
      await File('${dir.path}/mdfp_evidence_index.json').writeAsString('[]');
      final path = dir.path;
      // Each isolate has its own static queue, matching background workers.
      await Future.wait(List.generate(
          4,
          (worker) => Isolate.run(() async {
                final store = LocalEvidenceStore(directory: Directory(path));
                for (var i = 0; i < 8; i++) {
                  await store.saveItem(fixture('worker-$worker-$i'));
                }
              })));
      final items = await LocalEvidenceStore(directory: dir).getAllItems();
      expect(items.length, 32);
      expect(items.map((item) => item.localId).toSet().length, 32);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('corrupt index is not silently overwritten with an empty database',
      () async {
    final dir = await Directory.systemTemp.createTemp('mdfp-corrupt-');
    try {
      final index = File('${dir.path}/mdfp_evidence_index.json');
      await index.writeAsString('broken-index');
      final store = LocalEvidenceStore(directory: dir);
      await expectLater(store.saveItem(fixture('new')), throwsStateError);
      expect(await index.readAsString(), 'broken-index');
    } finally {
      await dir.delete(recursive: true);
    }
  });
}

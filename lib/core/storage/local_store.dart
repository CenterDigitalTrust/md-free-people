import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Модель збереженого доказу на пристрої
class EvidenceItem {
  final String localId;
  String? shortId;
  String? recordToken;
  final String mediaType;
  final String filePath;
  final String fileSha256;
  final int fileSize;
  final String canonicalJson;
  final String recordDigest;
  final String signature; // Base64 DER
  String status; // 'local', 'queued', 'anchored', 'simulated', 'failed'
  String vaultStatus; // 'pending', 'uploaded', 'skipped'
  String? solanaTx;
  String? blockTime;
  final int createdAtMs;
  final double? geoLat;
  final double? geoLon;
  final int? geoAcc;

  EvidenceItem({
    required this.localId,
    this.shortId,
    this.recordToken,
    required this.mediaType,
    required this.filePath,
    required this.fileSha256,
    required this.fileSize,
    required this.canonicalJson,
    required this.recordDigest,
    required this.signature,
    this.status = 'local',
    this.vaultStatus = 'pending',
    this.solanaTx,
    this.blockTime,
    required this.createdAtMs,
    this.geoLat,
    this.geoLon,
    this.geoAcc,
  });

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'shortId': shortId,
      'recordToken': recordToken,
      'mediaType': mediaType,
      'filePath': filePath,
      'fileSha256': fileSha256,
      'fileSize': fileSize,
      'canonicalJson': canonicalJson,
      'recordDigest': recordDigest,
      'signature': signature,
      'status': status,
      'vaultStatus': vaultStatus,
      'solanaTx': solanaTx,
      'blockTime': blockTime,
      'createdAtMs': createdAtMs,
      'geoLat': geoLat,
      'geoLon': geoLon,
      'geoAcc': geoAcc,
    };
  }

  factory EvidenceItem.fromMap(Map<String, dynamic> map) {
    return EvidenceItem(
      localId: map['localId'] as String,
      shortId: map['shortId'] as String?,
      recordToken: map['recordToken'] as String?,
      mediaType: map['mediaType'] as String? ?? 'video/mp4',
      filePath: map['filePath'] as String,
      fileSha256: map['fileSha256'] as String,
      fileSize: (map['fileSize'] as num).toInt(),
      canonicalJson: map['canonicalJson'] as String,
      recordDigest: map['recordDigest'] as String,
      signature: map['signature'] as String,
      status: map['status'] as String? ?? 'local',
      vaultStatus: map['vaultStatus'] as String? ?? 'pending',
      solanaTx: map['solanaTx'] as String?,
      blockTime: map['blockTime'] as String?,
      createdAtMs: (map['createdAtMs'] as num).toInt(),
      geoLat: (map['geoLat'] as num?)?.toDouble(),
      geoLon: (map['geoLon'] as num?)?.toDouble(),
      geoAcc: (map['geoAcc'] as num?)?.toInt(),
    );
  }
}

/// Захищене сховище доказів на пристрої.
/// Uses an atomic index in Android app-private storage; reads legacy secure storage.
/// та файлову систему додатку.
class LocalEvidenceStore {
  static Future<void> _pendingWrite = Future<void>.value();

  static const _indexKey = 'mdfp_evidence_index_v1';
  final FlutterSecureStorage _secureStorage;
  final Directory? _directory;

  LocalEvidenceStore(
      {FlutterSecureStorage? secureStorage, Directory? directory})
      : _directory = directory,
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Serialize writers, including Android workers in other Dart isolates.
  Future<T> _withWriteLock<T>(Future<T> Function() operation) async {
    final previous = _pendingWrite;
    final gate = Completer<void>();
    _pendingWrite = gate.future;
    await previous;
    File? lock;
    var ownsLock = false;
    try {
      final index = await _getIndexFallbackFile();
      // POSIX advisory locks are process-wide, so they cannot protect isolates.
      // Include Linux process start time: a crashed process cannot block restart.
      var session = '$pid';
      if (Platform.isAndroid || Platform.isLinux) {
        final stat = await File('/proc/self/stat').readAsString();
        final fields = stat.substring(stat.lastIndexOf(')') + 2).split(' ');
        session = '$pid-${fields[19]}';
      }
      lock = File('${index.path}.$session.writer');
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!ownsLock) {
        try {
          await lock.create(exclusive: true);
          ownsLock = true;
        } on FileSystemException catch (error) {
          // Windows can report a delete-pending lock as access denied rather
          // than already-existing. Retry only acquisition, never the write.
          final windowsContention = Platform.isWindows &&
              const [5, 32, 33].contains(error.osError?.errorCode);
          if (error is! PathExistsException && !windowsContention) rethrow;
          // Never steal a live writer's lock or overwrite its pending update.
          if (DateTime.now().isAfter(deadline)) {
            throw StateError(
                'Evidence storage is busy; restart the app and retry');
          }
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      }
      return await operation();
    } finally {
      try {
        if (ownsLock) await lock!.delete();
      } finally {
        gate.complete();
      }
    }
  }

  /// Persist newly captured evidence without losing concurrent records.
  Future<void> saveItem(EvidenceItem item) => _withWriteLock(() async {
        final items = await getAllItems();
        final index =
            items.indexWhere((existing) => existing.localId == item.localId);
        if (index >= 0) {
          _mergeProgress(items[index], item);
          items[index] = item;
        } else {
          items.insert(0, item);
        }
        await _saveIndex(items);
      });

  /// Update only existing records so a running worker cannot undo a user purge.
  Future<void> updateItem(EvidenceItem item) => _withWriteLock(() async {
        final items = await getAllItems();
        final index =
            items.indexWhere((existing) => existing.localId == item.localId);
        if (index < 0) return;
        _mergeProgress(items[index], item);
        items[index] = item;
        await _saveIndex(items);
      });

  void _mergeProgress(EvidenceItem saved, EvidenceItem incoming) {
    // Never regress an accepted record or an uploaded file on a stale retry.
    incoming.shortId ??= saved.shortId;
    incoming.recordToken ??= saved.recordToken;
    incoming.solanaTx ??= saved.solanaTx;
    incoming.blockTime ??= saved.blockTime;
    if (saved.status == 'anchored' ||
        saved.status == 'simulated' ||
        (saved.status == 'queued' && incoming.status == 'failed')) {
      incoming.status = saved.status;
    }
    if (saved.vaultStatus == 'uploaded') incoming.vaultStatus = 'uploaded';
  }

  /// Read the atomic file first; never turn a corrupt store into an empty list.
  Future<List<EvidenceItem>> getAllItems() async {
    final file = await _getIndexFallbackFile();
    try {
      final String? raw = await file.exists()
          ? await file.readAsString()
          : await _secureStorage.read(key: _indexKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
              (entry) => EvidenceItem.fromMap(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (error) {
      throw StateError(
          'Cannot read evidence index; existing data preserved: $error');
    }
  }

  /// Отримання доказу за localId
  Future<EvidenceItem?> getItemByLocalId(String localId) async {
    final items = await getAllItems();
    for (final it in items) {
      if (it.localId == localId) return it;
    }
    return null;
  }

  /// Отримання списку записів, готових до відправки (черга)
  Future<List<EvidenceItem>> getPendingQueue() async {
    final items = await getAllItems();
    return items
        .where((it) =>
            it.status == 'local' ||
            it.status == 'failed' ||
            (it.shortId != null && it.vaultStatus == 'pending'))
        .toList();
  }

  /// Видалення одного доказу
  Future<void> deleteItem(String localId) => _withWriteLock(() async {
        final items = await getAllItems();
        final itemToRemove =
            items.where((it) => it.localId == localId).firstOrNull;
        if (itemToRemove != null) {
          try {
            final f = File(itemToRemove.filePath);
            if (await f.exists()) await f.delete();
          } catch (error) {
            throw StateError("Cannot delete evidence file: $error");
          }
        }
        items.removeWhere((it) => it.localId == localId);
        await _saveIndex(items);
      });

  /// Повне очищення всіх даних на телефоні (Purge Local Data за ТЗ)
  Future<void> purgeAll() => _withWriteLock(() async {
        final items = await getAllItems();
        for (final it in items) {
          try {
            final f = File(it.filePath);
            if (await f.exists()) await f.delete();
          } catch (error) {
            throw StateError("Cannot delete evidence file: $error");
          }
        }
        // Remove copies created for Android sharing when purging local evidence.
        if (_directory == null) {
          final cache = await getTemporaryDirectory();
          final exports = Directory('${cache.path}/evidence_exports');
          if (await exports.exists()) await exports.delete(recursive: true);
        }
        await _secureStorage.delete(key: _indexKey);
        final fallbackFile = await _getIndexFallbackFile();
        if (await fallbackFile.exists()) {
          await fallbackFile.delete();
        }
      });

  Future<void> _saveIndex(List<EvidenceItem> items) async {
    // Commit atomically before reporting success; propagate disk errors.
    final encoded = jsonEncode(items.map((item) => item.toMap()).toList());
    final file = await _getIndexFallbackFile();
    final temp =
        File('${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');
    try {
      await temp.writeAsString(encoded, flush: true);
      await temp.rename(file.path);
    } catch (error) {
      throw FileSystemException(
          'Cannot persist evidence index: $error', file.path);
    }
  }

  Future<File> _getIndexFallbackFile() async {
    final dir = _directory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/mdfp_evidence_index.json');
  }
}

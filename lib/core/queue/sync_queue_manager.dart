import 'dart:convert';
import '../app_failure.dart';
import 'upload_policy.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../capture/capture_service.dart';
import '../crypto/key_signer_interface.dart';
import '../crypto/signer_factory.dart';
import '../storage/local_store.dart';

/// Менеджер черги відправки доказів (Offline Queue).
/// Забезпечує надійну синхронізацію:
/// 1. Відбиток (digest + канонічний JSON) відправляється завжди при появі мережі.
/// 2. Media follows the selected connected, unmetered, or manual policy.
/// 3. Повна стійкість до режиму польоту та перезапусків пристрою.
class SyncQueueManager {
  final LocalEvidenceStore _store;
  final KeySigner _signer;
  final http.Client _httpClient;

  String aggregatorUrl;
  String vaultUrl;

  bool _isProcessing = false;

  SyncQueueManager({
    LocalEvidenceStore? store,
    KeySigner? signer,
    http.Client? httpClient,
    this.aggregatorUrl = ApiConfig.api,
    this.vaultUrl = ApiConfig.vault,
  })  : _store = store ?? LocalEvidenceStore(),
        _signer = signer ?? SignerFactory.getSigner(),
        _httpClient = httpClient ?? http.Client();

  /// Додавання щойно зафіксованого доказу до черги
  Future<EvidenceItem> enqueueEvidence(CapturedEvidence evidence) async {
    final item = EvidenceItem(
      localId:
          'loc_${DateTime.now().millisecondsSinceEpoch}_${evidence.record.nonce.substring(0, 8)}',
      mediaType: evidence.mediaType,
      filePath: evidence.file.path,
      fileSha256: evidence.record.fileSha256,
      fileSize: evidence.record.fileSize,
      canonicalJson: evidence.canonicalJson,
      recordDigest: evidence.recordDigest,
      signature: evidence.signature.signature,
      status: 'local',
      vaultStatus: 'pending',
      createdAtMs: evidence.createdAtMs,
      geoLat: evidence.record.geo != null
          ? evidence.record.geo!.latE6 / 1000000.0
          : null,
      geoLon: evidence.record.geo != null
          ? evidence.record.geo!.lonE6 / 1000000.0
          : null,
      geoAcc: evidence.record.geo?.accM,
    );

    await _store.saveItem(item);

    // Спроба миттєвої відправки (якщо є інтернет)
    triggerSync();
    return item;
  }

  /// Асинхронний запуск обробки черги
  Future<void> triggerSync({bool isWifiConnected = false}) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await processQueue(isWifiConnected: isWifiConnected);
    } catch (error, stack) {
      developer.log('Queue sync failed', error: error, stackTrace: stack);
    } finally {
      _isProcessing = false;
    }
  }

  /// Основний цикл обробки черги
  Future<void> processQueue({bool isWifiConnected = false}) async {
    final uploadPolicy = await UploadPolicy.load();

    final pendingItems = await _store.getPendingQueue();

    for (final item in pendingItems) {
      try {
        // Етап 1: Відправка відбитку та канонічного запису до Агрегатора
        if (item.status == 'local' || item.status == 'failed') {
          final registeredDeviceId = await _ensureDeviceRegistered();
          if (registeredDeviceId == null) {
            // Немає зв'язку з сервером для реєстрації
            item.status = 'failed';
            await _store.updateItem(item);
            continue;
          }

          final response = await _httpClient
              .post(
                Uri.parse('$aggregatorUrl/v1/records'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'record': item.canonicalJson,
                  'signature': item.signature,
                }),
              )
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 202) {
            final data = jsonDecode(response.body);
            if (data['short_id'] is! String ||
                (data['short_id'] as String).isEmpty ||
                data['record_token'] is! String ||
                (data['record_token'] as String).isEmpty) {
              throw const FormatException(
                  'Missing record credentials in server response');
            }
            item.status = 'queued';
            item.shortId = data['short_id'] as String?;
            item.recordToken = data['record_token'] as String?;
            await _store.updateItem(item);
          } else {
            item.status = 'failed';
            await _store.updateItem(item);
            continue;
          }
        }

        // Етап 2: Відправка файлу у Vault за обраною політикою
        if (item.shortId != null && item.vaultStatus == 'pending') {
          final shouldUploadFile =
              UploadPolicy.allows(uploadPolicy, unmetered: isWifiConnected);
          if (shouldUploadFile &&
              item.shortId != null &&
              item.recordToken != null) {
            final file = File(item.filePath);
            if (await file.exists()) {
              final uploadSuccess = await _uploadFileToVault(
                shortId: item.shortId!,
                recordToken: item.recordToken!,
                file: file,
              );
              if (uploadSuccess) {
                item.vaultStatus = 'uploaded';
                await _store.updateItem(item);
              }
            }
          }
        }
      } catch (error, stack) {
        developer.log('Evidence sync failed', error: error, stackTrace: stack);
        // Офлайн (режим польоту або мережева помилка): залишаємо запис локально
        if (item.shortId == null) item.status = 'failed';
        await _store.updateItem(item);
      }
    }

    // Етап 3: Опитування статусу для записів у статусі 'queued'
    await pollQueuedRecords();
  }

  /// Опитування статусу підтвердження у блокчейні
  Future<void> pollQueuedRecords() async {
    final allItems = await _store.getAllItems();
    final queuedItems = allItems.where((it) => it.status == 'queued').toList();

    for (final item in queuedItems) {
      if (item.shortId == null || item.recordToken == null) continue;

      try {
        final res = await _httpClient
            .get(
              Uri.parse(
                  '$aggregatorUrl/v1/records/${item.shortId}?token=${item.recordToken}'),
            )
            .timeout(const Duration(seconds: 5));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final serverStatus = data['status'] as String? ?? 'queued';

          if (serverStatus == 'anchored' || serverStatus == 'finalized') {
            item.status = 'anchored';
            final anchor = data['receipt']?['anchor'];
            item.solanaTx = anchor?['tx_signature'] as String?;
            final seconds = anchor?['block_time'];
            item.blockTime = seconds is num
                ? DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000,
                        isUtc: true)
                    .toIso8601String()
                : seconds?.toString();
            await _store.updateItem(item);
          } else if (serverStatus == 'simulated') {
            item.status = 'simulated';
            await _store.updateItem(item);
          }
        }
      } catch (_) {
        // Пропускаємо у разі відсутності зв'язку
      }
    }
  }

  /// Завантаження файлу на незалежний сервер Vault
  Future<bool> _uploadFileToVault({
    required String shortId,
    required String recordToken,
    required File file,
  }) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$vaultUrl/upload'));
      request.fields['record_id'] = shortId;
      request.fields['record_token'] = recordToken;
      request.files.add(await http.MultipartFile.fromPath('media', file.path));

      final streamedResponse =
          await _httpClient.send(request).timeout(const Duration(minutes: 3));
      await streamedResponse.stream
          .drain<void>()
          .timeout(const Duration(minutes: 3));
      return streamedResponse.statusCode == 201 ||
          streamedResponse.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Перевірка та реєстрація пристрою на сервері
  Future<String?> _ensureDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final savedId = prefs.getString('mdfp_device_id');
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    try {
      // 1. Отримання challenge
      final chalRes = await _httpClient
          .post(
            Uri.parse('$aggregatorUrl/v1/devices/challenge'),
          )
          .timeout(const Duration(seconds: 5));
      if (chalRes.statusCode != 200) return null;
      final challenge = jsonDecode(chalRes.body)['challenge'] as String;

      // 2. Отримання публічного ключа з Keystore
      final pubKey = await _signer.getPublicKey();
      if (pubKey == null) return null;

      // 3. Реєстрація
      final regRes = await _httpClient
          .post(
            Uri.parse('$aggregatorUrl/v1/devices/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'public_key': pubKey.publicKeySpki,
              'alg': _signer.algorithm,
              'challenge': challenge,
              'model': 'Android Mobile Client',
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (regRes.statusCode == 200 || regRes.statusCode == 201) {
        final devId = jsonDecode(regRes.body)['device_id'] as String;
        await prefs.setString('mdfp_device_id', devId);
        return devId;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Upload one explicitly selected record regardless of automatic Wi-Fi policy.
  Future<void> uploadManually(String localId) async {
    await triggerSync();
    final item = await _store.getItemByLocalId(localId);
    if (item == null || item.shortId == null || item.recordToken == null) {
      throw const AppFailure('record_not_sent');
    }
    // Foreground synchronization may already have uploaded this file.
    if (item.vaultStatus == 'uploaded') return;
    if (!await _uploadFileToVault(
        shortId: item.shortId!,
        recordToken: item.recordToken!,
        file: File(item.filePath))) {
      throw const AppFailure('upload_error');
    }
    item.vaultStatus = 'uploaded';
    await _store.updateItem(item);
  }

  /// Register before signing: the server ID is part of immutable signed JSON.
  Future<String> prepareDevice() async {
    if (!await _signer.hasKey()) {
      await _signer.generateKey();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mdfp_device_id');
    }
    final id = await _ensureDeviceRegistered();
    if (id == null) {
      throw const AppFailure('device_registration_required');
    }
    return id;
  }
}

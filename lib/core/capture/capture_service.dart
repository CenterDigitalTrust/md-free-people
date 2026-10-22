import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import '../crypto/key_signer_interface.dart';
import '../crypto/signer_factory.dart';
import '../crypto/streaming_hasher.dart';
import '../protocol/mdfp_record.dart';

/// Результат повної фіксації медіафайлу за протоколом MDFP1
class CapturedEvidence {
  final File file;
  final String mediaType;
  final MdfpRecord record;
  final String canonicalJson;
  final String recordDigest;
  final SignatureResult signature;
  final String leafHash;
  final int createdAtMs;

  CapturedEvidence({
    required this.file,
    required this.mediaType,
    required this.record,
    required this.canonicalJson,
    required this.recordDigest,
    required this.signature,
    required this.leafHash,
    required this.createdAtMs,
  });
}

/// Сервіс фіксації доказів безпосередньо всередині додатка.
/// Гарантує виконання ланцюжка:
/// Закриття файлу -> Потоковий SHA-256 -> Канонічний JSON -> Апаратний підпис MDFP1 -> Листок Меркла.
class CaptureService {
  final KeySigner _signer;

  CaptureService({KeySigner? signer})
      : _signer = signer ?? SignerFactory.getSigner();

  /// Обчислення листка дерева Меркла за ТЗ 3.3:
  /// leaf = SHA-256(0x00 || record_digest || signature_bytes)
  static String computeMerkleLeaf(
      String recordDigestHex, Uint8List signatureBytes) {
    final digestBytes = _hexToBytes(recordDigestHex);
    final prefix = Uint8List.fromList([0x00]);
    final full =
        Uint8List(prefix.length + digestBytes.length + signatureBytes.length);
    full.setRange(0, prefix.length, prefix);
    full.setRange(
        prefix.length, prefix.length + digestBytes.length, digestBytes);
    full.setRange(
        prefix.length + digestBytes.length, full.length, signatureBytes);

    return sha256.convert(full).toString().toLowerCase();
  }

  /// Повна процедура створення фіксації для щойно відзнятого файлу
  Future<CapturedEvidence> processCapturedFile({
    required File file,
    required String mediaType,
    required String deviceId,
    String appVer = '1.0.3+4',
  }) async {
    // 1. Потокове обчислення SHA-256 та розміру файлу
    final hashResult = await StreamingHasher.hashFile(file);

    // 2. Отримання GPS координат (якщо дозволено користувачем, інакше null)
    MdfpGeo? geo;
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final LocationPermission permission =
            await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          geo = MdfpGeo.fromCoordinates(
            latitude: pos.latitude,
            longitude: pos.longitude,
            accuracy: pos.accuracy,
          );
        }
      }
    } catch (_) {
      // Геолокація недоступна або тайм-аут: згідно з ТЗ 3.1 geo опускається, нулі не підставляються
      geo = null;
    }

    // 3. Побудова канонічного запису MDFP1
    final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final String nonce = MdfpRecord.generateNonce();

    final record = MdfpRecord(
      v: 1,
      appVer: appVer,
      clientTimeMs: nowMs,
      deviceId: deviceId,
      fileSha256: hashResult.sha256Hex,
      fileSize: hashResult.byteLength,
      mediaType: mediaType,
      nonce: nonce,
      geo: geo,
    );

    final String canonicalJson = record.toCanonicalJson();
    final String recordDigest = record.getRecordDigest();

    // 4. Апаратний підпис над "MDFP1\n" + canonicalJson
    final Uint8List messageToSign = record.getMessageToSign();
    final SignatureResult signature = await _signer.signData(messageToSign);

    // 5. Розрахунок листка дерева Меркла
    final Uint8List signatureBytes = base64Decode(signature.signature);
    final String leafHash = computeMerkleLeaf(recordDigest, signatureBytes);

    return CapturedEvidence(
      file: file,
      mediaType: mediaType,
      record: record,
      canonicalJson: canonicalJson,
      recordDigest: recordDigest,
      signature: signature,
      leafHash: leafHash,
      createdAtMs: nowMs,
    );
  }

  /// Отримання захищеного внутрішнього каталогу для збереження доказів
  static Future<Directory> getEvidenceDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${docsDir.path}/mdfp_evidence');
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }
    return evidenceDir;
  }

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

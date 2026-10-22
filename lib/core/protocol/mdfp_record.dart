import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Геодані за ТЗ 3.1: цілі числа (lat_e6, lon_e6, acc_m)
class MdfpGeo {
  final int accM; // Точність у метрах (int)
  final int latE6; // Широта * 1 000 000 (int)
  final int lonE6; // Довгота * 1 000 000 (int)

  const MdfpGeo({
    required this.accM,
    required this.latE6,
    required this.lonE6,
  });

  /// Створення з градусів та точності
  factory MdfpGeo.fromCoordinates({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) {
    return MdfpGeo(
      accM: accuracy.round(),
      latE6: (latitude * 1000000).round(),
      lonE6: (longitude * 1000000).round(),
    );
  }

  Map<String, int> toMap() {
    return {
      'acc_m': accM,
      'lat_e6': latE6,
      'lon_e6': lonE6,
    };
  }
}

/// Канонічна фіксація медіадоказу за протоколом MDFP1 (ТЗ 3.1)
class MdfpRecord {
  final int v; // Версія схеми = 1
  final String appVer; // Версія додатка (напр. "1.0.0+1")
  final int clientTimeMs; // Час фіксації на пристрої у мс
  final String deviceId; // Ідентифікатор пристрою
  final String fileSha256; // SHA-256 хеш медіафайлу (64 hex)
  final int fileSize; // Точний розмір файлу в байтах
  final String mediaType; // MIME-тип: "image/jpeg", "video/mp4", "audio/m4a"
  final String nonce; // 16 байт випадковості (32 hex символи)
  final MdfpGeo? geo; // Геолокація (якщо доступна, інакше null)

  MdfpRecord({
    this.v = 1,
    required this.appVer,
    required this.clientTimeMs,
    required this.deviceId,
    required this.fileSha256,
    required this.fileSize,
    required this.mediaType,
    required this.nonce,
    this.geo,
  });

  /// Генерація 16 випадкових криптографічно стійких байт (32 hex)
  static String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Канонічна серіалізація JSON (ТЗ 3.1):
  /// - Алфавітний порядок ключів
  /// - Жодних пробілів або переносів рядків
  /// - Числа виключно цілі (int)
  /// - geo відсутній, якщо null (ніяких нулів)
  String toCanonicalJson() {
    final buffer = StringBuffer();
    buffer.write('{"app_ver":"$appVer",');
    buffer.write('"client_time_ms":$clientTimeMs,');
    buffer.write('"device_id":"$deviceId",');
    buffer.write('"file_sha256":"$fileSha256",');
    buffer.write('"file_size":$fileSize,');
    if (geo != null) {
      buffer.write(
          '"geo":{"acc_m":${geo!.accM},"lat_e6":${geo!.latE6},"lon_e6":${geo!.lonE6}},');
    }
    buffer.write('"media_type":"$mediaType",');
    buffer.write('"nonce":"$nonce",');
    buffer.write('"v":$v}');
    return buffer.toString();
  }

  /// Обчислення дайджесту канонічного запису:
  /// record_digest = SHA-256(canonical_record_bytes)
  String getRecordDigest() {
    final bytes = utf8.encode(toCanonicalJson());
    return sha256.convert(bytes).toString().toLowerCase();
  }

  /// Повідомлення для апаратного підпису за ТЗ 3.2:
  /// message = "MDFP1\n" || canonical_record_bytes
  Uint8List getMessageToSign() {
    final prefix = utf8.encode("MDFP1\n");
    final body = utf8.encode(toCanonicalJson());
    final out = Uint8List(prefix.length + body.length);
    out.setRange(0, prefix.length, prefix);
    out.setRange(prefix.length, out.length, body);
    return out;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'v': v,
      'app_ver': appVer,
      'client_time_ms': clientTimeMs,
      'device_id': deviceId,
      'file_sha256': fileSha256,
      'file_size': fileSize,
      'media_type': mediaType,
      'nonce': nonce,
    };
    if (geo != null) {
      map['geo'] = geo!.toMap();
    }
    return map;
  }
}

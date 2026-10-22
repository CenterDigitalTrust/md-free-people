import 'dart:io';
import 'package:crypto/crypto.dart';

/// Результат потокового обчислення гешу
class HashResult {
  final String sha256Hex;
  final int byteLength;

  HashResult({
    required this.sha256Hex,
    required this.byteLength,
  });
}

/// Потоковий обчислювач SHA-256 для медіафайлів будь-якого розміру (фото, довгі відео).
/// Не завантажує весь файл у пам'ять телефону, обробляє чанками.
class StreamingHasher {
  static Future<HashResult> hashFile(File file) async {
    if (!await file.exists()) {
      throw FileSystemException(
          'File does not exist for streaming hash', file.path);
    }

    final int byteLength = await file.length();
    final Digest digest = await sha256.bind(file.openRead()).first;

    return HashResult(
      sha256Hex: digest.toString().toLowerCase(),
      byteLength: byteLength,
    );
  }
}

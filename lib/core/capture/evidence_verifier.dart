import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../crypto/streaming_hasher.dart';
import '../storage/local_store.dart';

/// Checks local file and canonical record integrity without claiming chain finality.
class EvidenceVerifier {
  static Future<bool> verifyLocal(EvidenceItem item) async {
    // Stream media to avoid loading large video files into memory.
    try {
      final result = await StreamingHasher.hashFile(File(item.filePath));
      final record = jsonDecode(item.canonicalJson) as Map<String, dynamic>;
      return result.sha256Hex == item.fileSha256 &&
          result.byteLength == item.fileSize &&
          record['file_sha256'] == result.sha256Hex &&
          record['file_size'] == result.byteLength &&
          sha256.convert(utf8.encode(item.canonicalJson)).toString() ==
              item.recordDigest;
    } catch (error) {
      throw StateError('Не вдалося перевірити локальний файл: $error');
    }
  }
}

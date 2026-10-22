import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'key_signer_interface.dart';

/// Програмний тест-модуль для юніт-тестів та платформ без Android Keystore.
class SoftwareTestSigner implements KeySigner {
  bool _hasKey = false;

  // Фіксований тестовий вектор P-256
  static const String _mockSpkiHex =
      '3059301306072a8648ce3d020106082a8648ce3d03010703420004e1a49f57c838b931e921d4f2bc1c58209bb8044719bb8ec3792080a221295ba58253a6c75f0a8523cf3eb02e5b16e4566ff11ff3b5cf2b07e2cf6cbe26fa329c';
  static const String _mockUncompressedHex =
      '04e1a49f57c838b931e921d4f2bc1c58209bb8044719bb8ec3792080a221295ba58253a6c75f0a8523cf3eb02e5b16e4566ff11ff3b5cf2b07e2cf6cbe26fa329c';

  @override
  String get algorithm => 'ecdsa-p256-sha256';

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    return DeviceInfo(
      manufacturer: 'Emulator / Test',
      model: 'Software Test Provider',
      device: 'Simulator',
      apiLevel: 34,
      hasStrongBox: false,
      recommendedAlgorithm: 'ecdsa-p256-sha256',
      isHardwareSupported: false,
    );
  }

  @override
  Future<bool> hasKey({String alias = 'mdfp_device_key'}) async {
    return _hasKey;
  }

  @override
  Future<KeyGenerationResult> generateKey({
    String alias = 'mdfp_device_key',
    Uint8List? attestationChallenge,
  }) async {
    _hasKey = true;
    final spkiBytes = _hexToBytes(_mockSpkiHex);

    return KeyGenerationResult(
      alias: alias,
      algorithm: algorithm,
      publicKeySpki: base64Encode(spkiBytes),
      publicKeySpkiHex: _mockSpkiHex,
      publicKeyUncompressedHex: _mockUncompressedHex,
      securityLevel: 'Software',
      isStrongBox: false,
      attestationChain: [],
      attestationLevel: 'none',
    );
  }

  @override
  Future<PublicKeyResult?> getPublicKey(
      {String alias = 'mdfp_device_key'}) async {
    if (!_hasKey) return null;
    final spkiBytes = _hexToBytes(_mockSpkiHex);

    return PublicKeyResult(
      alias: alias,
      algorithm: algorithm,
      publicKeySpki: base64Encode(spkiBytes),
      publicKeySpkiHex: _mockSpkiHex,
      publicKeyUncompressedHex: _mockUncompressedHex,
    );
  }

  @override
  Future<SignatureResult> signData(
    Uint8List dataToSign, {
    String alias = 'mdfp_device_key',
  }) async {
    // Формуємо детермінований тестовий підпис ASN.1 DER (70 байт) для тестового вектора
    final digest = sha256.convert(dataToSign).bytes;
    final r = Uint8List.fromList(digest);
    final s = Uint8List.fromList(sha256.convert(digest).bytes);
    final der = _encodeDerSignature(r, s);

    return SignatureResult(
      signature: base64Encode(der),
      signatureHex: _bytesToHex(der),
      format: 'der',
      algorithm: algorithm,
    );
  }

  @override
  Future<List<String>> getAttestationChain(
      {String alias = 'mdfp_device_key'}) async {
    return [];
  }

  @override
  Future<bool> deleteKey({String alias = 'mdfp_device_key'}) async {
    _hasKey = false;
    return true;
  }

  Uint8List _encodeDerSignature(Uint8List r, Uint8List s) {
    List<int> rSeq = _encodeInteger(r);
    List<int> sSeq = _encodeInteger(s);
    List<int> body = [...rSeq, ...sSeq];
    return Uint8List.fromList([0x30, body.length, ...body]);
  }

  List<int> _encodeInteger(Uint8List val) {
    List<int> bytes = List.from(val);
    while (bytes.length > 1 && bytes[0] == 0) {
      bytes.removeAt(0);
    }
    if ((bytes[0] & 0x80) != 0) {
      bytes.insert(0, 0x00);
    }
    return [0x02, bytes.length, ...bytes];
  }

  Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

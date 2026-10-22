import 'dart:typed_data';

/// Результат запиту інформації про пристрій та апаратну безпеку
class DeviceInfo {
  final String manufacturer;
  final String model;
  final String device;
  final int apiLevel;
  final bool hasStrongBox;
  final String recommendedAlgorithm;
  final bool isHardwareSupported;

  DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.device,
    required this.apiLevel,
    required this.hasStrongBox,
    required this.recommendedAlgorithm,
    required this.isHardwareSupported,
  });

  factory DeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    return DeviceInfo(
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      model: map['model'] as String? ?? 'Unknown',
      device: map['device'] as String? ?? 'Unknown',
      apiLevel: (map['apiLevel'] as num?)?.toInt() ?? 0,
      hasStrongBox: map['hasStrongBox'] as bool? ?? false,
      recommendedAlgorithm:
          map['recommendedAlgorithm'] as String? ?? 'ecdsa-p256-sha256',
      isHardwareSupported: map['isHardwareSupported'] as bool? ?? true,
    );
  }
}

/// Результат генерації пари ключів
class KeyGenerationResult {
  final String alias;
  final String algorithm; // 'ecdsa-p256-sha256'
  final String publicKeySpki; // Base64 SPKI DER
  final String publicKeySpkiHex;
  final String publicKeyUncompressedHex; // 65 байт 04 || X || Y
  final String securityLevel; // 'StrongBox' або 'TEE'
  final bool isStrongBox;
  final List<String> attestationChain; // Base64 X.509 сертифікати
  final String attestationLevel; // 'strongbox', 'tee', 'none'

  KeyGenerationResult({
    required this.alias,
    required this.algorithm,
    required this.publicKeySpki,
    required this.publicKeySpkiHex,
    required this.publicKeyUncompressedHex,
    required this.securityLevel,
    required this.isStrongBox,
    required this.attestationChain,
    required this.attestationLevel,
  });

  factory KeyGenerationResult.fromMap(Map<dynamic, dynamic> map) {
    return KeyGenerationResult(
      alias: map['alias'] as String? ?? '',
      algorithm: map['algorithm'] as String? ?? 'ecdsa-p256-sha256',
      publicKeySpki: map['publicKeySpki'] as String? ?? '',
      publicKeySpkiHex: map['publicKeySpkiHex'] as String? ?? '',
      publicKeyUncompressedHex:
          map['publicKeyUncompressedHex'] as String? ?? '',
      securityLevel: map['securityLevel'] as String? ?? 'TEE',
      isStrongBox: map['isStrongBox'] as bool? ?? false,
      attestationChain: (map['attestationChain'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      attestationLevel: map['attestationLevel'] as String? ?? 'none',
    );
  }
}

/// Результат читання публічного ключа
class PublicKeyResult {
  final String alias;
  final String algorithm;
  final String publicKeySpki;
  final String publicKeySpkiHex;
  final String publicKeyUncompressedHex;

  PublicKeyResult({
    required this.alias,
    required this.algorithm,
    required this.publicKeySpki,
    required this.publicKeySpkiHex,
    required this.publicKeyUncompressedHex,
  });

  factory PublicKeyResult.fromMap(Map<dynamic, dynamic> map) {
    return PublicKeyResult(
      alias: map['alias'] as String? ?? '',
      algorithm: map['algorithm'] as String? ?? 'ecdsa-p256-sha256',
      publicKeySpki: map['publicKeySpki'] as String? ?? '',
      publicKeySpkiHex: map['publicKeySpkiHex'] as String? ?? '',
      publicKeyUncompressedHex:
          map['publicKeyUncompressedHex'] as String? ?? '',
    );
  }
}

/// Результат апаратного підпису
class SignatureResult {
  final String signature; // Base64 DER
  final String signatureHex;
  final String format; // 'der'
  final String algorithm; // 'ecdsa-p256-sha256'

  SignatureResult({
    required this.signature,
    required this.signatureHex,
    required this.format,
    required this.algorithm,
  });

  factory SignatureResult.fromMap(Map<dynamic, dynamic> map) {
    return SignatureResult(
      signature: map['signature'] as String? ?? '',
      signatureHex: map['signatureHex'] as String? ?? '',
      format: map['format'] as String? ?? 'der',
      algorithm: map['algorithm'] as String? ?? 'ecdsa-p256-sha256',
    );
  }
}

/// Абстрактний інтерфейс криптографічного модуля апаратного підпису.
/// Забезпечує уніфікацію для Android Keystore та майбутнього iOS Secure Enclave.
abstract class KeySigner {
  /// Ідентифікатор криптографічного алгоритму за ТЗ (ecdsa-p256-sha256)
  String get algorithm;

  /// Отримання інформації про платформу
  Future<DeviceInfo> getDeviceInfo();

  /// Перевірка наявності ключа
  Future<bool> hasKey({String alias = 'mdfp_device_key'});

  /// Генерація пари ключів в апаратному сховищі
  Future<KeyGenerationResult> generateKey({
    String alias = 'mdfp_device_key',
    Uint8List? attestationChallenge,
  });

  /// Отримання публічного ключа
  Future<PublicKeyResult?> getPublicKey({String alias = 'mdfp_device_key'});

  /// Апаратний підпис довільних байт (SHA256withECDSA)
  Future<SignatureResult> signData(
    Uint8List dataToSign, {
    String alias = 'mdfp_device_key',
  });

  /// Отримання ланцюжка сертифікатів атестації
  Future<List<String>> getAttestationChain({String alias = 'mdfp_device_key'});

  /// Видалення ключа
  Future<bool> deleteKey({String alias = 'mdfp_device_key'});
}

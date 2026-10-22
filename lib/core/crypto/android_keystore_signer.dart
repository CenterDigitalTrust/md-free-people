import 'package:flutter/services.dart';
import 'key_signer_interface.dart';

/// Реалізація KeySigner на базі Android Keystore через нативний MethodChannel.
class AndroidKeystoreSigner implements KeySigner {
  static const MethodChannel _channel =
      MethodChannel('org.mdsystem.mdfp/keystore');

  @override
  String get algorithm => 'ecdsa-p256-sha256';

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('getDeviceInfo');
    if (result == null) {
      throw Exception('Failed to get device info from Android Keystore');
    }
    return DeviceInfo.fromMap(result);
  }

  @override
  Future<bool> hasKey({String alias = 'mdfp_device_key'}) async {
    final bool? result =
        await _channel.invokeMethod('hasKey', {'alias': alias});
    return result ?? false;
  }

  @override
  Future<KeyGenerationResult> generateKey({
    String alias = 'mdfp_device_key',
    Uint8List? attestationChallenge,
  }) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('generateKey', {
      'alias': alias,
      'challenge': attestationChallenge,
    });
    if (result == null) {
      throw Exception('Failed to generate key pair in Android Keystore');
    }
    return KeyGenerationResult.fromMap(result);
  }

  @override
  Future<PublicKeyResult?> getPublicKey(
      {String alias = 'mdfp_device_key'}) async {
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod('getPublicKey', {
        'alias': alias,
      });
      if (result == null) return null;
      return PublicKeyResult.fromMap(result);
    } on PlatformException catch (e) {
      if (e.code == 'KEY_NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<SignatureResult> signData(
    Uint8List dataToSign, {
    String alias = 'mdfp_device_key',
  }) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('signData', {
      'alias': alias,
      'data': dataToSign,
    });
    if (result == null) {
      throw Exception('Failed to sign data using Android Keystore');
    }
    return SignatureResult.fromMap(result);
  }

  @override
  Future<List<String>> getAttestationChain(
      {String alias = 'mdfp_device_key'}) async {
    final List<dynamic>? result =
        await _channel.invokeMethod('getAttestationChain', {
      'alias': alias,
    });
    return result?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Future<bool> deleteKey({String alias = 'mdfp_device_key'}) async {
    final bool? result =
        await _channel.invokeMethod('deleteKey', {'alias': alias});
    return result ?? false;
  }
}

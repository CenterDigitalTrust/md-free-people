import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'key_signer_interface.dart';
import 'android_keystore_signer.dart';
import 'mock_software_signer.dart';

/// Фабрика криптографічного модуля апаратного підпису.
/// Автоматично вибирає AndroidKeystoreSigner на платформі Android
/// або SoftwareTestSigner на симуляторах / робочих станціях тестування.
class SignerFactory {
  static KeySigner? _instance;

  static KeySigner getSigner() {
    if (_instance != null) return _instance!;

    if (!kIsWeb && Platform.isAndroid) {
      _instance = AndroidKeystoreSigner();
    } else {
      _instance = SoftwareTestSigner();
    }
    return _instance!;
  }

  /// Метод заміщення для модульного тестування
  static void setMockSigner(KeySigner mock) {
    _instance = mock;
  }

  /// Скидання інстансу
  static void reset() {
    _instance = null;
  }
}

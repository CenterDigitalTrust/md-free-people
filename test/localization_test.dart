import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdfp_app/core/localization/app_localizations.dart';

void main() {
  group('Localization Tests (uk, en, ru, ja, es)', () {
    const requiredLocales = ['uk', 'en', 'ru', 'ja', 'es'];

    test('Supported locales list matches exact 5 required languages', () {
      final supportedCodes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(supportedCodes, equals(requiredLocales));
      expect(supportedCodes.contains('de'), isFalse);
      expect(supportedCodes.contains('fr'), isFalse);
    });

    test('All 5 ARB files exist, are valid JSON, and have key parity', () {
      final arbDir = Directory('lib/l10n');
      expect(arbDir.existsSync(), isTrue, reason: 'lib/l10n must exist');

      final baseKeys = <String>{};

      for (final code in requiredLocales) {
        final arbFile = File('lib/l10n/app_$code.arb');
        expect(arbFile.existsSync(), isTrue,
            reason: 'app_$code.arb must exist in lib/l10n');

        final content = arbFile.readAsStringSync();
        final Map<String, dynamic> jsonMap = jsonDecode(content);

        expect(jsonMap['@@locale'], equals(code));

        final keys = jsonMap.keys.where((k) => !k.startsWith('@')).toSet();
        if (baseKeys.isEmpty) {
          baseKeys.addAll(keys);
        } else {
          // Verify 100% key parity
          final missingInCurrent = baseKeys.difference(keys);
          final extraInCurrent = keys.difference(baseKeys);
          expect(missingInCurrent, isEmpty,
              reason: 'app_$code.arb is missing keys: $missingInCurrent');
          expect(extraInCurrent, isEmpty,
              reason: 'app_$code.arb has extra keys: $extraInCurrent');
        }
      }

      expect(baseKeys.length, greaterThanOrEqualTo(40),
          reason: 'Must have at least 40 translation keys');
    });

    test('AppLocalizations translation fallback and placeholder test', () {
      for (final code in requiredLocales) {
        final loc = AppLocalizations(Locale(code));
        expect(loc.translate('app_title').isNotEmpty, isTrue);
        expect(loc.translate('disclaimer').isNotEmpty, isTrue);
        expect(loc.translate('geo_note').isNotEmpty, isTrue);

        // Test placeholder replacement
        final recordedText =
            loc.translate('recorded_by', params: {'time': '12:00 UTC'});
        expect(
            recordedText.contains('12:00 UTC') ||
                recordedText.contains('12:00'),
            isTrue);
      }
    });

    test('Japanese specific checks: kanji/kana and date formatting', () {
      final jaLoc = AppLocalizations(const Locale('ja'));

      // Check key translations per Spec 6.8
      expect(
        jaLoc.translate('disclaimer'),
        equals('記録後にファイルが変更されていないことを確認します。出来事の内容は評価しません。'),
      );
      expect(
        jaLoc.translate('geo_note'),
        equals('位置情報は端末が報告した値です。'),
      );
      expect(
        jaLoc.translate('verify_fail'),
        equals('ファイルは記録と異なります。'),
      );
      expect(
        jaLoc.translate('testnet_note'),
        equals('（テストネット）'),
      );

      // Check Japanese date formatting: yyyy年M月d日 H:mm
      final testDate = DateTime(2026, 10, 11, 13, 1);
      final formattedJaDate = jaLoc.formatDateTime(testDate);
      expect(formattedJaDate, equals('2026年10月11日 13:01'));
    });

    test('Spanish and Ukrainian long text strings do not crash or return empty',
        () {
      final esLoc = AppLocalizations(const Locale('es'));
      final ukLoc = AppLocalizations(const Locale('uk'));

      expect(esLoc.translate('disclaimer').length, greaterThan(50));
      expect(ukLoc.translate('disclaimer').length, greaterThan(50));
      expect(esLoc.translate('btn_purge_data'),
          equals('Eliminar datos en el teléfono'));
      expect(ukLoc.translate('btn_purge_data'),
          equals('Видалити дані на телефоні'));
    });
  });
}

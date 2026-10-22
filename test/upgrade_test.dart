import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mdfp_app/core/localization/app_localizations.dart';
import 'package:mdfp_app/core/queue/upload_policy.dart';
import 'package:mdfp_app/core/queue/sync_queue_manager.dart';
import 'package:mdfp_app/screens/settings_screen.dart';
import 'package:mdfp_app/screens/onboarding_screen.dart';
import 'package:mdfp_app/screens/record_detail_screen.dart';
import 'evidence_pipeline_test.dart' show fixture, MemoryStore;

Widget localized(LocaleProvider provider, Widget screen) {
  // Rebuild the entire route tree when the stored language changes.
  return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<LocaleProvider>(
        builder: (context, value, child) => MaterialApp(
            locale: value.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!),
            home: screen),
      ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
      'runtime catalogue matches every ARB value and placeholder in all languages',
      () {
    final base = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
    final placeholders = RegExp(r'\{\w+\}');
    for (final locale in AppLocalizations.supportedLocales) {
      final data = jsonDecode(File('lib/l10n/app_${locale.languageCode}.arb')
          .readAsStringSync()) as Map<String, dynamic>;
      final loc = AppLocalizations(locale);
      for (final entry in data.entries.where((e) => !e.key.startsWith('@'))) {
        expect(loc.translate(entry.key), entry.value,
            reason: '${locale.languageCode}/${entry.key}');
        expect(
            placeholders
                .allMatches(entry.value as String)
                .map((m) => m.group(0))
                .toSet(),
            placeholders
                .allMatches(base[entry.key] as String)
                .map((m) => m.group(0))
                .toSet());
      }
    }
  });

  test('selected language survives provider recreation', () async {
    final first = LocaleProvider();
    await first.setLocale(const Locale('es'));
    final second = LocaleProvider();
    await second.restore();
    expect(second.locale, const Locale('es'));
    await second.setLocale(const Locale('invalid'));
    expect(second.locale, const Locale('es'));
    first.dispose();
    second.dispose();
  });

  test(
      'upgrade enables cellular once but preserves manual and later Wi-Fi choices',
      () async {
    SharedPreferences.setMockInitialValues({'file_upload_policy': 'wifi'});
    expect(await UploadPolicy.load(), 'any');
    await UploadPolicy.save('wifi');
    expect(await UploadPolicy.load(), 'wifi');
    SharedPreferences.setMockInitialValues({'file_upload_policy': 'manual'});
    expect(await UploadPolicy.load(), 'manual');
  });

  for (final policy in UploadPolicy.values) {
    for (final wifi in [false, true]) {
      test('real multipart file request: policy=$policy unmetered=$wifi',
          () async {
        await UploadPolicy.save(policy);
        final dir = await Directory.systemTemp.createTemp('mdfp-cellular-');
        try {
          final file = await File('${dir.path}/original.jpg')
              .writeAsString('actual media bytes');
          final item = fixture('cellular', status: 'anchored', path: file.path)
            ..shortId = 'record'
            ..recordToken = 'private-token';
          var uploads = 0;
          final client = MockClient((request) async {
            expect(request.url.path, '/vault/upload');
            expect(request.headers['content-type'],
                startsWith('multipart/form-data'));
            expect(request.body, contains('actual media bytes'));
            expect(request.body, contains('private-token'));
            uploads++;
            return http.Response('{}', 201);
          });
          await SyncQueueManager(store: MemoryStore([item]), httpClient: client)
              .processQueue(isWifiConnected: wifi);
          final allowed = policy == 'any' || (policy == 'wifi' && wifi);
          expect(uploads, allowed ? 1 : 0);
          expect(item.vaultStatus, allowed ? 'uploaded' : 'pending');
          client.close();
        } finally {
          await dir.delete(recursive: true);
        }
      });
    }
  }

  for (final code in ['uk', 'en', 'ru', 'es', 'ja']) {
    testWidgets(
        'onboarding/settings/details render in $code at 320px and large text',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = LocaleProvider();
      await provider.setLocale(Locale(code));
      final loc = AppLocalizations(Locale(code));
      await tester
          .pumpWidget(localized(provider, OnboardingScreen(onFinish: () {})));
      await tester.pumpAndSettle();
      expect(find.text(loc.translate('app_title')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(loc.translate('btn_continue')));
      await tester.pumpAndSettle();
      expect(find.text(loc.translate('perm_camera')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(localized(provider, const SettingsScreen()));
      await tester.pumpAndSettle();
      for (var i = 0; i < 12; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -350));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('1.0.3+4'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      final item = fixture('visible', status: 'anchored')
        ..solanaTx = 'tx'
        ..blockTime = '2026-10-22T12:00:00Z';
      await tester
          .pumpWidget(localized(provider, RecordDetailScreen(item: item)));
      await tester.pumpAndSettle();
      expect(
          find.text(
              '${loc.translate('status_label')}: ${loc.recordStatus('anchored')}'),
          findsOneWidget);
      await tester.scrollUntilVisible(
          find.text(loc.translate('copy_receipt')).hitTestable(), 200,
          scrollable: find
              .descendant(
                  of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(loc.translate('copy_receipt')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.text(loc.translate('record_not_sent')).hitTestable(), 150,
          scrollable: find
              .descendant(
                  of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      expect(find.text(loc.translate('record_not_sent')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    });
  }
}

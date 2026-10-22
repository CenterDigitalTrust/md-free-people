import 'dart:convert';
import 'dart:io';

void main() {
  // Generate the runtime map from ARB, never maintain a second manual catalogue.
  try {
    final catalogs = <String, Map<String, dynamic>>{};
    for (final code in ['uk', 'en', 'ru', 'es', 'ja']) {
      final data = jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
      catalogs[code] = Map.fromEntries(
          data.entries.where((entry) => !entry.key.startsWith('@')));
    }
    final json = const JsonEncoder.withIndent('  ')
        .convert(catalogs)
        .replaceAll(r'$', r'\$');
    File('lib/core/localization/translations.g.dart').writeAsStringSync(
        '// GENERATED from lib/l10n/*.arb. Run dart run tool/generate_translations.dart.\n'
        'const translations = $json;\n');
  } catch (error) {
    stderr.writeln('Translation generation failed: $error');
    exitCode = 1;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.g.dart';

class AppLocalizations {
  final Locale locale;
  static const List<Locale> supportedLocales = [
    Locale('uk'),
    Locale('en'),
    Locale('ru'),
    Locale('ja'),
    Locale('es'),
  ];

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('uk'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _localizedValues = translations;

  String translate(String key, {Map<String, String>? params}) {
    final langCode = locale.languageCode;
    String text =
        _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (params != null) {
      params.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value);
      });
    }
    return text;
  }

  String recordStatus(String status) {
    // Unknown server states remain understandable instead of leaking raw codes.
    const keys = {
      'local': 'status_on_device',
      'queued': 'status_queued',
      'anchored': 'status_anchored',
      'simulated': 'status_simulated',
      'failed': 'status_failed'
    };
    return translate(keys[status] ?? 'status_unknown');
  }

  String vaultStatus(String status) => translate(status == 'uploaded'
      ? 'vault_uploaded'
      : status == 'pending'
          ? 'vault_pending'
          : 'status_unknown');

  String fileSize(int size) => translate('bytes', params: {'count': '$size'});

  String formatDateTime(DateTime dt) {
    if (locale.languageCode == 'ja') {
      return DateFormat('yyyy年M月d日 H:mm').format(dt);
    } else if (locale.languageCode == 'en') {
      return DateFormat('MM/dd/yyyy HH:mm').format(dt);
    } else if (locale.languageCode == 'es') {
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(dt);
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['uk', 'en', 'ru', 'ja', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uk');
  Locale get locale => _locale;

  Future<void> restore() async {
    // Restore before building the app to avoid a flash in the wrong language.
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = Locale(prefs.getString('app_language') ?? 'uk');
      if (AppLocalizations.supportedLocales.contains(saved)) _locale = saved;
    } catch (error) {
      debugPrint('Cannot restore app language: $error');
    }
  }

  Future<void> setLocale(Locale loc) async {
    // Persist before publishing the selected language to all routes.
    if (!AppLocalizations.supportedLocales.contains(loc)) return;
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('app_language', loc.languageCode)) {
      throw StateError('Could not persist language');
    }
    _locale = loc;
    notifyListeners();
  }
}

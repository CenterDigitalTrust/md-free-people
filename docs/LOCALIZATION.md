# Localization

Edit the five catalogs in `lib/l10n/`: `app_uk.arb`, `app_en.arb`, `app_ru.arb`, `app_es.arb`, `app_ja.arb`. Preserve matching keys and interpolation parameters.

```sh
dart run tool/generate_translations.dart && dart format lib/core/localization/translations.g.dart && flutter gen-l10n && flutter test --no-pub
```

Commit source catalogs and regenerated Dart files. Do not hand-edit `translations.g.dart` or files in `lib/core/localization/generated/`. Tests compare runtime values and placeholder sets.

Developer attribution is `ГО “Центр цифрової довіри”` in Ukrainian/Russian and `NGO Center for Digital Trust` in English/Spanish/Japanese. The surrounding label is localized. Language names remain autonyms; Android system dialogs follow the system language.

Widget tests cover 320 px width and 130% text scaling. Review long translations on a device too.

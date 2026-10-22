# Сборка и установка

## Среда

Проверенная версия: Flutter 3.24.5 (Dart 3.5.4), Java 17, Android SDK platform 35, build-tools 34.0.0. Gradle 8.9 загружается через включённый wrapper. Minimum Android API 26, target API 35. Другие платформы не подготовлены к выпуску.

Flutter и Java должны быть доступны через PATH; JAVA_HOME указывает на JDK 17, ANDROID_HOME — на Android SDK. Запустите `flutter doctor -v` и примите лицензии SDK командой `flutter doctor --android-licenses`. Машинные пути сохраняются в игнорируемом `android/local.properties`; в общих файлах абсолютных путей к E: нет.

## Проверка и тестовый APK — PowerShell

Выполните из корня репозитория:

```powershell
$ErrorActionPreference = 'Stop'
try {
    # Stop immediately if any tool reports an unsuccessful exit code.
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dependency restore failed' }
    dart run tool/generate_translations.dart
    if ($LASTEXITCODE -ne 0) { throw 'Translation generation failed' }
    dart format lib/core/localization/translations.g.dart
    if ($LASTEXITCODE -ne 0) { throw 'Formatting failed' }
    flutter analyze --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Static analysis failed' }
    flutter test --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Tests failed' }
    flutter build apk --release --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'APK build failed' }
} catch {
    Write-Error "Build stopped: $($_.Exception.Message)"
    exit 1
}
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`. По умолчанию используется локальный debug-ключ Android: это тестовая сборка. Ключ предыдущего APK в репозиторий не включён. APK, собранный на другом компьютере с другим ключом, не сможет обновить установленную версию поверх неё.

## Release-подпись

Создайте защищённый ключ вне репозитория с интерактивным вводом пароля. Создайте локальный `android/key.properties` с параметрами `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. `storeFile` — абсолютный путь или путь относительно `android`; на Windows используйте `/`. Файл и ключи исключены из Git. При неполной конфигурации Gradle останавливает сборку вместо незаметного перехода к debug-подписи.

После настройки ключа выполните ту же команду release-сборки. Сохраните ключ в защищённой резервной копии. Публикация в магазин — отдельная процедура. [Официальное руководство Flutter](https://docs.flutter.dev/deployment/android).

## Серверы

Сборка принимает `--dart-define=API_BASE_URL=...` и `--dart-define=VAULT_BASE_URL=...`; это публичные адреса, не секреты. Значения по умолчанию: `https://api.digitaltrust.living` и `https://api.digitaltrust.living/vault`. Аргументы передаются `flutter run` или `flutter build apk`. Токены записей выдаются сервером во время работы и не встраиваются в APK.

Инфраструктура Azure и Solana сюда не включена. Обычные тесты используют моделируемый HTTP и не отправляют реальные медиа на сервер.

## Устройство

Установите совместимо подписанный APK поверх прежнего приложения. Проверьте языки после перезапуска, разработчика, иконку, запись фото/видео/аудио. Отключите Wi-Fi и проверьте небольшой файл по мобильной сети в режиме «Wi-Fi и мобильная сеть», затем ручной режим и ограничение нетарифицируемой сетью. Для первой регистрации нужен API.

Android может откладывать фоновую отправку. Проверка целостности не доказывает подлинность события. Не удаляйте приложение ради обновления без сохранения нужных локальных данных.

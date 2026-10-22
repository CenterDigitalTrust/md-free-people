import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsGeneratedRu extends AppLocalizationsGenerated {
  AppLocalizationsGeneratedRu([String locale = 'ru']) : super(locale);

  @override
  String get app_title => 'MD Вільні люди';

  @override
  String get tagline => 'Зафиксируй. Подтверди. Передай.';

  @override
  String get card1_title => 'Снимай только в приложении';

  @override
  String get card1_desc => 'Импорт из галереи отключён. Снимайте в приложении, чтобы создать подписанный отпечаток файла.';

  @override
  String get card2_title => 'Чего приложение не делает';

  @override
  String get card2_desc => 'Не оценивает события, не устанавливает личность и не удостоверяет обстоятельства.';

  @override
  String get card3_title => 'Подпись на телефоне, отпечаток в блокчейне';

  @override
  String get card3_desc => 'Android хранит закрытый ключ в Keystore. Аппаратная защита зависит от устройства; аттестация не подтверждена.';

  @override
  String get btn_continue => 'Продолжить';

  @override
  String get disclaimer => 'Подтверждает, что файл не менялся с момента фиксации. Не оценивает содержание события.';

  @override
  String get geo_note => 'Геолокация — по данным устройства.';

  @override
  String recorded_by(String time) {
    return 'Зафиксировано не позднее: $time';
  }

  @override
  String verify_ok(String time) {
    return 'Файл совпадает с зафиксированным. Не менялся с $time.';
  }

  @override
  String get verify_fail => 'Файл отличается от зафиксированного.';

  @override
  String get testnet_note => '(тестовая сеть)';

  @override
  String get nav_capture => 'Съёмка';

  @override
  String get nav_records => 'Мои записи';

  @override
  String get nav_verify => 'Проверка';

  @override
  String get nav_settings => 'Настройки';

  @override
  String get mode_photo => 'Фото';

  @override
  String get mode_video => 'Видео';

  @override
  String get mode_audio => 'Аудио';

  @override
  String get capture_footer_note => 'Снято в приложении. Загрузка из галереи отключена.';

  @override
  String get no_connection_note => 'нет связи: сохраним на телефоне';

  @override
  String get status_on_device => 'На телефоне';

  @override
  String get status_queued => 'Отправлено';

  @override
  String get status_anchored => 'Подтверждено';

  @override
  String get status_simulated => 'Тестовая запись';

  @override
  String get file_upload_policy => 'Отправка файлов';

  @override
  String get file_upload_manual => 'Вручную';

  @override
  String get file_upload_wifi => 'Только по Wi-Fi';

  @override
  String get file_upload_desc => 'Отпечаток уходит всегда, а сам файл на независимый сервер — только если разрешено вами.';

  @override
  String get record_detail_title => 'Карточка записи';

  @override
  String get device_attestation_title => 'Устройство';

  @override
  String get attestation_not_verified => 'аттестация не подтверждена';

  @override
  String get btn_share_cert => 'Поделиться сертификатом (PDF)';

  @override
  String get btn_share_receipt => 'Поделиться квитанцией (.mdfp.json)';

  @override
  String get btn_send_file_vault => 'Отправить файл на независимый сервер';

  @override
  String get btn_select_file => 'Выбрать файл';

  @override
  String get btn_scan_qr => 'Сканировать QR';

  @override
  String get tech_info_title => 'Показать техническую информацию';

  @override
  String get settings_language => 'Язык приложения';

  @override
  String get btn_purge_data => 'Удалить данные на телефоне';

  @override
  String get purge_confirm_desc => 'Локальные файлы будут удалены безвозвратно, включая ещё не отправленные. Копии на сервере не удаляются. Solana Devnet — тестовая сеть, её записи могут быть сброшены.';

  @override
  String get app_version => 'Версия приложения';

  @override
  String get perm_camera => 'Камера: для съёмки доказательств внутри приложения.';

  @override
  String get perm_mic => 'Микрофон: для видео- и аудиофиксации событий.';

  @override
  String get perm_location => 'Геолокация: фиксация координат устройства (можно отклонить).';

  @override
  String get file_unchanged_header => 'ФАЙЛ НЕ ИЗМЕНЁН';

  @override
  String get finish_recording => 'Сначала завершите запись.';

  @override
  String get settings_error => 'Не удалось сохранить настройки. Повторите попытку.';

  @override
  String get storage_error => 'Не удалось прочитать сохранённые записи. Повторите попытку.';

  @override
  String get camera_permission => 'Разрешите доступ к камере в настройках Android.';

  @override
  String get microphone_permission => 'Разрешите доступ к микрофону в настройках Android.';

  @override
  String get camera_unavailable => 'Камера недоступна. Попробуйте подключиться снова.';

  @override
  String get audio_not_saved => 'Не удалось сохранить аудиозапись.';

  @override
  String get capture_error => 'Не удалось записать или сохранить файл. Проверьте разрешения и свободное место, затем повторите попытку.';

  @override
  String get device_registration_required => 'Для первой регистрации устройства нужен интернет. Повторите попытку подключения.';

  @override
  String get capture_saved => 'Запись сохранена и подписана. Статус отправки — в разделе «Мои записи».';

  @override
  String get capture_network_note => 'Solana Devnet • GPS добавляется при наличии';

  @override
  String get connect_camera => 'Подключить устройство и камеру';

  @override
  String get start_capture => 'Снять / начать запись';

  @override
  String get stop_capture => 'Остановить запись';

  @override
  String get refresh => 'Обновить';

  @override
  String get records_empty => 'Пока нет записей';

  @override
  String get status_failed => 'Ожидает повторной отправки';

  @override
  String get status_unknown => 'Неизвестный статус';

  @override
  String get vault_pending => 'Ожидает загрузки';

  @override
  String get vault_uploaded => 'Загружено';

  @override
  String get status_label => 'Статус';

  @override
  String bytes(String count) {
    return '$count байт';
  }

  @override
  String get file_label => 'Файл';

  @override
  String get signature_label => 'Подпись';

  @override
  String get size_label => 'Размер';

  @override
  String get gps_missing => 'GPS: не получен';

  @override
  String gps_coordinates(String lat, String lon, String accuracy) {
    return 'GPS: $lat, $lon ±$accuracy м';
  }

  @override
  String get unknown => 'Неизвестно';

  @override
  String get block_time => 'Время блока';

  @override
  String get public_digest => 'Публичный хеш записи (для проверки включения):';

  @override
  String get copy_digest => 'Копировать хеш записи';

  @override
  String get copy_success => 'Скопировано в буфер обмена.';

  @override
  String get copy_error => 'Не удалось скопировать в буфер обмена.';

  @override
  String get uploading => 'Подождите…';

  @override
  String get upload_file => 'Загрузить файл в Vault';

  @override
  String get copy_receipt => 'Копировать JSON-квитанцию';

  @override
  String get share_original => 'Поделиться оригинальным файлом';

  @override
  String get record_not_sent => 'Дождитесь регистрации записи на сервере.';

  @override
  String get receipt_not_ready => 'Квитанция ещё не готова. Повторите после подтверждения в блокчейне.';

  @override
  String get receipt_copied => 'Квитанция скопирована. Вставьте её на verify.digitaltrust.living вместе с файлом. Она содержит метаданные записи.';

  @override
  String get receipt_error => 'Не удалось получить квитанцию. Проверьте интернет и повторите попытку.';

  @override
  String get share_error => 'Не удалось поделиться файлом. Проверьте, что оригинал ещё хранится на устройстве.';

  @override
  String get upload_success => 'Файл загружен в Vault.';

  @override
  String get upload_error => 'Vault не принял файл. Проверьте интернет и повторите попытку.';

  @override
  String get devnet_disclaimer => 'Solana Devnet — тестовая сеть. Подпись и хеш не подтверждают правдивость содержания.';

  @override
  String get verify_title => 'Проверка целостности';

  @override
  String get verify_help => 'Выберите сохранённую запись для проверки её хеша SHA-256.';

  @override
  String get verify_empty => 'Нет локальных файлов для проверки.';

  @override
  String get verify_local_ok => 'SHA-256, размер файла и хеш записи совпадают. Это локальная проверка целостности; подпись устройства и транзакция блокчейна здесь не проверяются.';

  @override
  String get verify_local_fail => 'Файл или запись изменены: проверка целостности не пройдена.';

  @override
  String get verify_error => 'Не удалось проверить файл. Убедитесь, что оригинал ещё хранится на устройстве.';

  @override
  String get file_upload_any => 'Wi-Fi и мобильный интернет (4G/5G)';

  @override
  String get upload_any_desc => 'Автоматическая загрузка файлов через любую сеть. Расходует мобильный трафик.';

  @override
  String get upload_wifi_desc => 'Автоматическая загрузка медиа только через сеть без ограничения трафика (обычно Wi-Fi).';

  @override
  String get upload_manual_desc => 'Загружать медиа только по нажатию кнопки в карточке записи.';

  @override
  String get security_section => 'Безопасность и локальные данные';

  @override
  String get delete_device => 'Удаление с устройства';

  @override
  String get about => 'О приложении';

  @override
  String get organization => 'ГО “Центр цифрової довіри”';

  @override
  String get protocol => 'Протокол';

  @override
  String get key_protection => 'Защита ключа';

  @override
  String get keystore_unverified => 'Android Keystore (аттестация не подтверждена)';

  @override
  String get software_test => 'Программный ключ (тестовый режим)';

  @override
  String get server_label => 'Сервер регистрации';

  @override
  String get network_label => 'Сеть блокчейна';

  @override
  String get development => 'Разработка';

  @override
  String get purge_title => 'Удалить все локальные данные?';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete_all => 'Удалить всё';

  @override
  String get purge_error => 'Не удалось удалить все локальные данные. Повторите попытку.';

  @override
  String get purge_success => 'Локальные файлы удалены с устройства.';

  @override
  String get developed_by => 'Разработано';
}

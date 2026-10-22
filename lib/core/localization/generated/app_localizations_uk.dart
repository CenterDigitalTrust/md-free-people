import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsGeneratedUk extends AppLocalizationsGenerated {
  AppLocalizationsGeneratedUk([String locale = 'uk']) : super(locale);

  @override
  String get app_title => 'MD Вільні люди';

  @override
  String get tagline => 'Зафіксуй. Підтверди. Передай.';

  @override
  String get card1_title => 'Знімай тільки в додатку';

  @override
  String get card1_desc => 'Імпорт із галереї вимкнено. Знімайте в застосунку, щоб створити підписаний відбиток файлу.';

  @override
  String get card2_title => 'Чого додаток не робить';

  @override
  String get card2_desc => 'Не оцінює зміст подій, не встановлює особу та не гарантує обставин.';

  @override
  String get card3_title => 'Підпис на телефоні, відбиток у блокчейні';

  @override
  String get card3_desc => 'Android зберігає закритий ключ у Keystore. Апаратний захист залежить від пристрою; атестацію не підтверджено.';

  @override
  String get btn_continue => 'Продовжити';

  @override
  String get disclaimer => 'Підтверджує, що файл не змінювався з моменту фіксації. Не оцінює зміст події.';

  @override
  String get geo_note => 'Геолокація — за даними пристрою.';

  @override
  String recorded_by(String time) {
    return 'Зафіксовано не пізніше: $time';
  }

  @override
  String verify_ok(String time) {
    return 'Файл збігається із зафіксованим. Не змінювався з $time.';
  }

  @override
  String get verify_fail => 'Файл відрізняється від зафіксованого.';

  @override
  String get testnet_note => '(тестова мережа)';

  @override
  String get nav_capture => 'Зйомка';

  @override
  String get nav_records => 'Мої записи';

  @override
  String get nav_verify => 'Перевірка';

  @override
  String get nav_settings => 'Налаштування';

  @override
  String get mode_photo => 'Фото';

  @override
  String get mode_video => 'Відео';

  @override
  String get mode_audio => 'Аудіо';

  @override
  String get capture_footer_note => 'Знято в додатку. Завантаження з галереї відключено.';

  @override
  String get no_connection_note => 'немає зв\'язку: збережемо на телефоні';

  @override
  String get status_on_device => 'На телефоні';

  @override
  String get status_queued => 'Відправлено';

  @override
  String get status_anchored => 'Підтверджено';

  @override
  String get status_simulated => 'Тестовий запис';

  @override
  String get file_upload_policy => 'Відправка файлів';

  @override
  String get file_upload_manual => 'Вручну';

  @override
  String get file_upload_wifi => 'Тільки по Wi-Fi';

  @override
  String get file_upload_desc => 'Відбиток відправляється завжди, а сам файл на незалежний сервер — тільки за вашим вибором.';

  @override
  String get record_detail_title => 'Картка запису';

  @override
  String get device_attestation_title => 'Пристрій';

  @override
  String get attestation_not_verified => 'атестація не підтверджена';

  @override
  String get btn_share_cert => 'Поділитися сертифікатом (PDF)';

  @override
  String get btn_share_receipt => 'Поділитися квитанцією (.mdfp.json)';

  @override
  String get btn_send_file_vault => 'Відправити файл на незалежний сервер';

  @override
  String get btn_select_file => 'Вибрати файл';

  @override
  String get btn_scan_qr => 'Сканувати QR';

  @override
  String get tech_info_title => 'Показати технічну інформацію';

  @override
  String get settings_language => 'Мова додатку';

  @override
  String get btn_purge_data => 'Видалити дані на телефоні';

  @override
  String get purge_confirm_desc => 'Локальні файли буде видалено назавжди, включно з іще не надісланими. Копії на сервері не видаляються. Solana Devnet — тестова мережа, її записи можуть бути скинуті.';

  @override
  String get app_version => 'Версія додатку';

  @override
  String get perm_camera => 'Камера: для зйомки доказів всередині додатку.';

  @override
  String get perm_mic => 'Мікрофон: для відео та аудіофіксації подій.';

  @override
  String get perm_location => 'Геолокація: фіксація координат пристрою (можна відхилити).';

  @override
  String get file_unchanged_header => 'ФАЙЛ НЕ ЗМІНЕНО';

  @override
  String get finish_recording => 'Спочатку завершіть запис.';

  @override
  String get settings_error => 'Не вдалося зберегти налаштування. Спробуйте ще раз.';

  @override
  String get storage_error => 'Не вдалося прочитати збережені записи. Спробуйте ще раз.';

  @override
  String get camera_permission => 'Надайте доступ до камери в налаштуваннях Android.';

  @override
  String get microphone_permission => 'Надайте доступ до мікрофона в налаштуваннях Android.';

  @override
  String get camera_unavailable => 'Камера недоступна. Спробуйте підключитися ще раз.';

  @override
  String get audio_not_saved => 'Не вдалося зберегти аудіозапис.';

  @override
  String get capture_error => 'Не вдалося записати або зберегти файл. Перевірте дозволи та вільне місце й повторіть спробу.';

  @override
  String get device_registration_required => 'Для першої реєстрації пристрою потрібен інтернет. Повторіть спробу підключення.';

  @override
  String get capture_saved => 'Запис збережено та підписано. Статус надсилання — у розділі «Мої записи».';

  @override
  String get capture_network_note => 'Solana Devnet • GPS додається за наявності';

  @override
  String get connect_camera => 'Підключити пристрій і камеру';

  @override
  String get start_capture => 'Зняти / почати запис';

  @override
  String get stop_capture => 'Зупинити запис';

  @override
  String get refresh => 'Оновити';

  @override
  String get records_empty => 'Поки немає записів';

  @override
  String get status_failed => 'Очікує повторного надсилання';

  @override
  String get status_unknown => 'Невідомий статус';

  @override
  String get vault_pending => 'Очікує завантаження';

  @override
  String get vault_uploaded => 'Завантажено';

  @override
  String get status_label => 'Статус';

  @override
  String bytes(String count) {
    return '$count байт';
  }

  @override
  String get file_label => 'Файл';

  @override
  String get signature_label => 'Підпис';

  @override
  String get size_label => 'Розмір';

  @override
  String get gps_missing => 'GPS: не отримано';

  @override
  String gps_coordinates(String lat, String lon, String accuracy) {
    return 'GPS: $lat, $lon ±$accuracy м';
  }

  @override
  String get unknown => 'Невідомо';

  @override
  String get block_time => 'Час блоку';

  @override
  String get public_digest => 'Публічний хеш запису (для перевірки включення):';

  @override
  String get copy_digest => 'Копіювати хеш запису';

  @override
  String get copy_success => 'Скопійовано до буфера обміну.';

  @override
  String get copy_error => 'Не вдалося скопіювати до буфера обміну.';

  @override
  String get uploading => 'Зачекайте…';

  @override
  String get upload_file => 'Завантажити файл у Vault';

  @override
  String get copy_receipt => 'Копіювати JSON-квитанцію';

  @override
  String get share_original => 'Поділитися оригінальним файлом';

  @override
  String get record_not_sent => 'Дочекайтеся реєстрації запису на сервері.';

  @override
  String get receipt_not_ready => 'Квитанція ще не готова. Повторіть після підтвердження в блокчейні.';

  @override
  String get receipt_copied => 'Квитанцію скопійовано. Вставте її на verify.digitaltrust.living разом із файлом. Вона містить метадані запису.';

  @override
  String get receipt_error => 'Не вдалося отримати квитанцію. Перевірте інтернет і повторіть спробу.';

  @override
  String get share_error => 'Не вдалося поділитися файлом. Перевірте, чи оригінал ще зберігається на пристрої.';

  @override
  String get upload_success => 'Файл завантажено у Vault.';

  @override
  String get upload_error => 'Vault не прийняв файл. Перевірте інтернет і повторіть спробу.';

  @override
  String get devnet_disclaimer => 'Solana Devnet — тестова мережа. Підпис і хеш не підтверджують правдивість змісту.';

  @override
  String get verify_title => 'Перевірка цілісності';

  @override
  String get verify_help => 'Виберіть збережений запис для перевірки його хешу SHA-256.';

  @override
  String get verify_empty => 'Немає локальних файлів для перевірки.';

  @override
  String get verify_local_ok => 'SHA-256, розмір файлу та хеш запису збігаються. Це локальна перевірка цілісності; підпис пристрою та транзакція блокчейну тут не перевіряються.';

  @override
  String get verify_local_fail => 'Файл або запис змінено: перевірку цілісності не пройдено.';

  @override
  String get verify_error => 'Не вдалося перевірити файл. Переконайтеся, що оригінал ще зберігається на пристрої.';

  @override
  String get file_upload_any => 'Wi-Fi і мобільний інтернет (4G/5G)';

  @override
  String get upload_any_desc => 'Автоматичне завантаження файлів через будь-яку мережу. Використовує мобільний трафік.';

  @override
  String get upload_wifi_desc => 'Автоматичне завантаження медіа лише через мережу без обмеження трафіку (зазвичай Wi-Fi).';

  @override
  String get upload_manual_desc => 'Завантажувати медіа лише після натискання кнопки в картці запису.';

  @override
  String get security_section => 'Безпека та локальні дані';

  @override
  String get delete_device => 'Видалення з пристрою';

  @override
  String get about => 'Про застосунок';

  @override
  String get organization => 'ГО “Центр цифрової довіри”';

  @override
  String get protocol => 'Протокол';

  @override
  String get key_protection => 'Захист ключа';

  @override
  String get keystore_unverified => 'Android Keystore (атестацію не підтверджено)';

  @override
  String get software_test => 'Програмний ключ (тестовий режим)';

  @override
  String get server_label => 'Сервер реєстрації';

  @override
  String get network_label => 'Мережа блокчейну';

  @override
  String get development => 'Розробка';

  @override
  String get purge_title => 'Видалити всі локальні дані?';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete_all => 'Видалити все';

  @override
  String get purge_error => 'Не вдалося видалити всі локальні дані. Спробуйте ще раз.';

  @override
  String get purge_success => 'Локальні файли видалено з пристрою.';

  @override
  String get developed_by => 'Розроблено';
}

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsGeneratedJa extends AppLocalizationsGenerated {
  AppLocalizationsGeneratedJa([String locale = 'ja']) : super(locale);

  @override
  String get app_title => 'MD Free People';

  @override
  String get tagline => '記録。検証。届ける。';

  @override
  String get card1_title => 'アプリ内のみで撮影';

  @override
  String get card1_desc => 'ギャラリーからの読み込みは無効です。アプリ内で記録し、署名付きのファイル指紋を作成します。';

  @override
  String get card2_title => 'アプリが証明しないこと';

  @override
  String get card2_desc => '出来事の内容、個人の身元、状況の妥当性は評価・証明しません。';

  @override
  String get card3_title => '端末で署名、ブロックチェーンに刻印';

  @override
  String get card3_desc => 'Androidは秘密鍵をKeystoreに保存します。ハードウェア保護は端末によって異なり、認証は未確認です。';

  @override
  String get btn_continue => '続ける';

  @override
  String get disclaimer => '記録後にファイルが変更されていないことを確認します。出来事の内容は評価しません。';

  @override
  String get geo_note => '位置情報は端末が報告した値です。';

  @override
  String recorded_by(String time) {
    return '$time までに記録';
  }

  @override
  String verify_ok(String time) {
    return 'ファイルは記録と一致しています。$time から変更されていません。';
  }

  @override
  String get verify_fail => 'ファイルは記録と異なります。';

  @override
  String get testnet_note => '（テストネット）';

  @override
  String get nav_capture => '撮影';

  @override
  String get nav_records => 'マイ記録';

  @override
  String get nav_verify => '検証';

  @override
  String get nav_settings => '設定';

  @override
  String get mode_photo => '写真';

  @override
  String get mode_video => '動画';

  @override
  String get mode_audio => '音声';

  @override
  String get capture_footer_note => 'アプリ内で撮影。ギャラリーからの選択は無効です。';

  @override
  String get no_connection_note => 'オフライン：端末に保存中';

  @override
  String get status_on_device => '端末に保存';

  @override
  String get status_queued => '送信完了';

  @override
  String get status_anchored => '確定済み';

  @override
  String get status_simulated => 'テスト記録';

  @override
  String get file_upload_policy => 'ファイル送信設定';

  @override
  String get file_upload_manual => '手動送信';

  @override
  String get file_upload_wifi => 'Wi-Fi時のみ';

  @override
  String get file_upload_desc => 'ハッシュは常に送信されますが、ファイル自体は許可した場合のみ独立サーバーに送信されます。';

  @override
  String get record_detail_title => '記録の詳細';

  @override
  String get device_attestation_title => '端末情報';

  @override
  String get attestation_not_verified => 'アテスト未確認';

  @override
  String get btn_share_cert => '証明書を共有 (PDF)';

  @override
  String get btn_share_receipt => '領収書を共有 (.mdfp.json)';

  @override
  String get btn_send_file_vault => '独立保管サーバーにファイルを送信';

  @override
  String get btn_select_file => 'ファイルを選択';

  @override
  String get btn_scan_qr => 'QRコードをスキャン';

  @override
  String get tech_info_title => '技術詳細を表示';

  @override
  String get settings_language => '言語設定';

  @override
  String get btn_purge_data => '端末内のデータを完全削除';

  @override
  String get purge_confirm_desc => '未送信分も含め端末内のファイルを完全に削除します。サーバーのコピーは削除しません。Solana Devnetはテストネットであり、記録がリセットされる場合があります。';

  @override
  String get app_version => 'アプリバージョン';

  @override
  String get perm_camera => 'カメラ：アプリ内で証拠を撮影するために使用します。';

  @override
  String get perm_mic => 'マイク：出来事の動画および音声記録に使用します。';

  @override
  String get perm_location => '位置情報：端末の座標を記録します（拒否可能）。';

  @override
  String get file_unchanged_header => 'ファイルは変更されていません';

  @override
  String get finish_recording => '先に録画・録音を終了してください。';

  @override
  String get settings_error => '設定を保存できませんでした。もう一度お試しください。';

  @override
  String get storage_error => '保存した記録を読み込めませんでした。もう一度お試しください。';

  @override
  String get camera_permission => 'Androidの設定でカメラへのアクセスを許可してください。';

  @override
  String get microphone_permission => 'Androidの設定でマイクへのアクセスを許可してください。';

  @override
  String get camera_unavailable => 'カメラを利用できません。再接続してください。';

  @override
  String get audio_not_saved => '音声を保存できませんでした。';

  @override
  String get capture_error => '記録または保存ができませんでした。権限と空き容量を確認して再試行してください。';

  @override
  String get device_registration_required => '端末の初回登録にはインターネット接続が必要です。再試行してください。';

  @override
  String get capture_saved => '記録を保存して署名しました。送信状況は記録一覧で確認できます。';

  @override
  String get capture_network_note => 'Solana Devnet • 取得できた場合はGPSを付加';

  @override
  String get connect_camera => '端末とカメラを接続';

  @override
  String get start_capture => '撮影・録音を開始';

  @override
  String get stop_capture => '記録を停止';

  @override
  String get refresh => '更新';

  @override
  String get records_empty => '記録はまだありません';

  @override
  String get status_failed => '再送信待ち';

  @override
  String get status_unknown => '状態不明';

  @override
  String get vault_pending => 'アップロード待ち';

  @override
  String get vault_uploaded => 'アップロード済み';

  @override
  String get status_label => '状態';

  @override
  String bytes(String count) {
    return '$count バイト';
  }

  @override
  String get file_label => 'ファイル';

  @override
  String get signature_label => '署名';

  @override
  String get size_label => 'サイズ';

  @override
  String get gps_missing => 'GPS：未取得';

  @override
  String gps_coordinates(String lat, String lon, String accuracy) {
    return 'GPS：$lat, $lon ±$accuracy m';
  }

  @override
  String get unknown => '不明';

  @override
  String get block_time => 'ブロック時刻';

  @override
  String get public_digest => '記録の公開ダイジェスト（包含検証用）：';

  @override
  String get copy_digest => 'ダイジェストをコピー';

  @override
  String get copy_success => 'クリップボードにコピーしました。';

  @override
  String get copy_error => 'クリップボードにコピーできませんでした。';

  @override
  String get uploading => 'お待ちください…';

  @override
  String get upload_file => 'ファイルをVaultに送信';

  @override
  String get copy_receipt => 'JSON受領証をコピー';

  @override
  String get share_original => '元のファイルを共有';

  @override
  String get record_not_sent => '記録がサーバーに登録されるまでお待ちください。';

  @override
  String get receipt_not_ready => '受領証は未作成です。ブロックチェーンでの確認後に再試行してください。';

  @override
  String get receipt_copied => '受領証をコピーしました。ファイルとともにverify.digitaltrust.livingで使用してください。記録のメタデータが含まれています。';

  @override
  String get receipt_error => '受領証を取得できませんでした。接続を確認して再試行してください。';

  @override
  String get share_error => 'ファイルを共有できませんでした。元のファイルが端末に残っているか確認してください。';

  @override
  String get upload_success => 'ファイルをVaultに送信しました。';

  @override
  String get upload_error => 'Vaultへの送信に失敗しました。接続を確認して再試行してください。';

  @override
  String get devnet_disclaimer => 'Solana Devnetはテストネットです。署名やハッシュは内容の真実性を証明しません。';

  @override
  String get verify_title => '整合性の確認';

  @override
  String get verify_help => '保存した記録を選択してSHA-256ハッシュを確認してください。';

  @override
  String get verify_empty => '確認するローカルファイルがありません。';

  @override
  String get verify_local_ok => 'SHA-256、サイズ、記録のダイジェストが一致します。ローカルでの整合性確認です。端末の署名やブロックチェーンの取引はここでは検証しません。';

  @override
  String get verify_local_fail => 'ファイルまたは記録が変更されています。整合性を確認できませんでした。';

  @override
  String get verify_error => '確認できませんでした。元のファイルが端末に残っているか確認してください。';

  @override
  String get file_upload_any => 'Wi-Fiとモバイル通信（4G/5G）';

  @override
  String get upload_any_desc => '接続があれば自動送信します。モバイルデータ通信量を消費します。';

  @override
  String get upload_wifi_desc => '従量制ではない接続（通常はWi-Fi）のみで自動送信します。';

  @override
  String get upload_manual_desc => '記録の詳細画面でボタンを押したときのみ送信します。';

  @override
  String get security_section => 'セキュリティと端末内のデータ';

  @override
  String get delete_device => '端末から削除';

  @override
  String get about => 'アプリについて';

  @override
  String get organization => 'NGO Center for Digital Trust';

  @override
  String get protocol => 'プロトコル';

  @override
  String get key_protection => '鍵の保護';

  @override
  String get keystore_unverified => 'Android Keystore（認証未確認）';

  @override
  String get software_test => 'ソフトウェア鍵（テストモード）';

  @override
  String get server_label => '登録サーバー';

  @override
  String get network_label => 'ブロックチェーンネットワーク';

  @override
  String get development => '開発';

  @override
  String get purge_title => '端末内のデータをすべて削除しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete_all => 'すべて削除';

  @override
  String get purge_error => 'すべてのローカルデータを削除できませんでした。再試行してください。';

  @override
  String get purge_success => '端末内のファイルを削除しました。';

  @override
  String get developed_by => '開発元';
}

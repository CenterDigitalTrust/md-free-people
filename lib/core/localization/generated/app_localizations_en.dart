import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsGeneratedEn extends AppLocalizationsGenerated {
  AppLocalizationsGeneratedEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'MD Free People';

  @override
  String get tagline => 'Record. Verify. Deliver.';

  @override
  String get card1_title => 'Capture only in the app';

  @override
  String get card1_desc => 'Gallery import is disabled. Record directly in the app to create a signed file fingerprint.';

  @override
  String get card2_title => 'What the app does not do';

  @override
  String get card2_desc => 'Does not assess events, verify personal identity, or validate circumstances.';

  @override
  String get card3_title => 'Signed on device, anchored on-chain';

  @override
  String get card3_desc => 'Android stores the private key in Keystore. Hardware protection depends on the device; attestation is not confirmed.';

  @override
  String get btn_continue => 'Continue';

  @override
  String get disclaimer => 'Confirms the file has not been changed since it was recorded. Does not assess what the recording shows.';

  @override
  String get geo_note => 'Location is as reported by the device.';

  @override
  String recorded_by(String time) {
    return 'Recorded no later than: $time';
  }

  @override
  String verify_ok(String time) {
    return 'The file matches the recorded one. Unchanged since $time.';
  }

  @override
  String get verify_fail => 'The file differs from the recorded one.';

  @override
  String get testnet_note => '(test network)';

  @override
  String get nav_capture => 'Capture';

  @override
  String get nav_records => 'My Records';

  @override
  String get nav_verify => 'Verify';

  @override
  String get nav_settings => 'Settings';

  @override
  String get mode_photo => 'Photo';

  @override
  String get mode_video => 'Video';

  @override
  String get mode_audio => 'Audio';

  @override
  String get capture_footer_note => 'Captured in app. Gallery upload is disabled.';

  @override
  String get no_connection_note => 'offline: saving locally';

  @override
  String get status_on_device => 'On device';

  @override
  String get status_queued => 'Sent';

  @override
  String get status_anchored => 'Confirmed';

  @override
  String get status_simulated => 'Test record';

  @override
  String get file_upload_policy => 'File Upload';

  @override
  String get file_upload_manual => 'Manual';

  @override
  String get file_upload_wifi => 'Wi-Fi Only';

  @override
  String get file_upload_desc => 'Hash digest is always sent, media file goes to independent vault only if permitted.';

  @override
  String get record_detail_title => 'Record Details';

  @override
  String get device_attestation_title => 'Device';

  @override
  String get attestation_not_verified => 'attestation unconfirmed';

  @override
  String get btn_share_cert => 'Share Certificate (PDF)';

  @override
  String get btn_share_receipt => 'Share Receipt (.mdfp.json)';

  @override
  String get btn_send_file_vault => 'Send file to independent vault';

  @override
  String get btn_select_file => 'Select File';

  @override
  String get btn_scan_qr => 'Scan QR';

  @override
  String get tech_info_title => 'Show Technical Information';

  @override
  String get settings_language => 'App Language';

  @override
  String get btn_purge_data => 'Purge Local Data';

  @override
  String get purge_confirm_desc => 'This permanently deletes local files, including any not yet uploaded. Server copies are not deleted. Solana Devnet is a test network and records may be reset.';

  @override
  String get app_version => 'App Version';

  @override
  String get perm_camera => 'Camera: to capture evidence within the app.';

  @override
  String get perm_mic => 'Microphone: for video and audio recording of events.';

  @override
  String get perm_location => 'Location: records device coordinates (optional).';

  @override
  String get file_unchanged_header => 'FILE UNCHANGED';

  @override
  String get finish_recording => 'Finish recording first.';

  @override
  String get settings_error => 'Could not save settings. Please try again.';

  @override
  String get storage_error => 'Could not read saved records. Please try again.';

  @override
  String get camera_permission => 'Allow camera access in Android settings.';

  @override
  String get microphone_permission => 'Allow microphone access in Android settings.';

  @override
  String get camera_unavailable => 'Camera is unavailable. Try reconnecting.';

  @override
  String get audio_not_saved => 'Could not save the audio recording.';

  @override
  String get capture_error => 'Could not record or save the file. Check permissions and free space, then retry.';

  @override
  String get device_registration_required => 'An internet connection is required for initial device registration. Please retry.';

  @override
  String get capture_saved => 'Recording saved and signed. See My Records for upload status.';

  @override
  String get capture_network_note => 'Solana Devnet • GPS included when available';

  @override
  String get connect_camera => 'Connect device and camera';

  @override
  String get start_capture => 'Capture / start recording';

  @override
  String get stop_capture => 'Stop recording';

  @override
  String get refresh => 'Refresh';

  @override
  String get records_empty => 'No recordings yet';

  @override
  String get status_failed => 'Waiting to retry';

  @override
  String get status_unknown => 'Unknown status';

  @override
  String get vault_pending => 'Waiting to upload';

  @override
  String get vault_uploaded => 'Uploaded';

  @override
  String get status_label => 'Status';

  @override
  String bytes(String count) {
    return '$count bytes';
  }

  @override
  String get file_label => 'File';

  @override
  String get signature_label => 'Signature';

  @override
  String get size_label => 'Size';

  @override
  String get gps_missing => 'GPS: not available';

  @override
  String gps_coordinates(String lat, String lon, String accuracy) {
    return 'GPS: $lat, $lon ±$accuracy m';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get block_time => 'Block time';

  @override
  String get public_digest => 'Public record digest (for inclusion verification):';

  @override
  String get copy_digest => 'Copy digest';

  @override
  String get copy_success => 'Copied to clipboard.';

  @override
  String get copy_error => 'Could not copy to clipboard.';

  @override
  String get uploading => 'Please wait…';

  @override
  String get upload_file => 'Upload file to Vault';

  @override
  String get copy_receipt => 'Copy JSON receipt';

  @override
  String get share_original => 'Share original file';

  @override
  String get record_not_sent => 'Wait until the record is registered on the server.';

  @override
  String get receipt_not_ready => 'Receipt is not ready. Retry after blockchain confirmation.';

  @override
  String get receipt_copied => 'Receipt copied. Paste it at verify.digitaltrust.living together with the file. It contains recording metadata.';

  @override
  String get receipt_error => 'Could not retrieve the receipt. Check your connection and retry.';

  @override
  String get share_error => 'Could not share the file. Check that the original is still on this device.';

  @override
  String get upload_success => 'File uploaded to Vault.';

  @override
  String get upload_error => 'Vault did not accept the file. Check your connection and retry.';

  @override
  String get devnet_disclaimer => 'Solana Devnet is a test network. Signatures and hashes do not prove the truth of the content.';

  @override
  String get verify_title => 'Integrity check';

  @override
  String get verify_help => 'Select a saved record to check its SHA-256 hash.';

  @override
  String get verify_empty => 'No local files to verify.';

  @override
  String get verify_local_ok => 'SHA-256, file size and record digest match. This is a local integrity check; the device signature and blockchain transaction are not checked here.';

  @override
  String get verify_local_fail => 'File or record changed: integrity check failed.';

  @override
  String get verify_error => 'Could not verify the file. Check that the original is still on this device.';

  @override
  String get file_upload_any => 'Wi-Fi and mobile data (4G/5G)';

  @override
  String get upload_any_desc => 'Automatically upload files on any connection. Uses your mobile data allowance.';

  @override
  String get upload_wifi_desc => 'Automatically upload media only on an unmetered connection (usually Wi-Fi).';

  @override
  String get upload_manual_desc => 'Upload media only when you press the button in record details.';

  @override
  String get security_section => 'Security and local data';

  @override
  String get delete_device => 'Delete from device';

  @override
  String get about => 'About the app';

  @override
  String get organization => 'NGO Center for Digital Trust';

  @override
  String get protocol => 'Protocol';

  @override
  String get key_protection => 'Key protection';

  @override
  String get keystore_unverified => 'Android Keystore (attestation unconfirmed)';

  @override
  String get software_test => 'Software key (test mode)';

  @override
  String get server_label => 'Registration server';

  @override
  String get network_label => 'Blockchain network';

  @override
  String get development => 'Development';

  @override
  String get purge_title => 'Delete all local data?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete_all => 'Delete all';

  @override
  String get purge_error => 'Could not delete all local data. Please try again.';

  @override
  String get purge_success => 'Local files deleted from this device.';

  @override
  String get developed_by => 'Developed by';
}

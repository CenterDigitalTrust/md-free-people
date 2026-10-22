import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizationsGenerated
/// returned by `AppLocalizationsGenerated.of(context)`.
///
/// Applications need to include `AppLocalizationsGenerated.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizationsGenerated.localizationsDelegates,
///   supportedLocales: AppLocalizationsGenerated.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizationsGenerated.supportedLocales
/// property.
abstract class AppLocalizationsGenerated {
  AppLocalizationsGenerated(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizationsGenerated? of(BuildContext context) {
    return Localizations.of<AppLocalizationsGenerated>(context, AppLocalizationsGenerated);
  }

  static const LocalizationsDelegate<AppLocalizationsGenerated> delegate = _AppLocalizationsGeneratedDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ru'),
    Locale('uk')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'MD Free People'**
  String get app_title;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Record. Verify. Deliver.'**
  String get tagline;

  /// No description provided for @card1_title.
  ///
  /// In en, this message translates to:
  /// **'Capture only in the app'**
  String get card1_title;

  /// No description provided for @card1_desc.
  ///
  /// In en, this message translates to:
  /// **'Gallery import is disabled. Record directly in the app to create a signed file fingerprint.'**
  String get card1_desc;

  /// No description provided for @card2_title.
  ///
  /// In en, this message translates to:
  /// **'What the app does not do'**
  String get card2_title;

  /// No description provided for @card2_desc.
  ///
  /// In en, this message translates to:
  /// **'Does not assess events, verify personal identity, or validate circumstances.'**
  String get card2_desc;

  /// No description provided for @card3_title.
  ///
  /// In en, this message translates to:
  /// **'Signed on device, anchored on-chain'**
  String get card3_title;

  /// No description provided for @card3_desc.
  ///
  /// In en, this message translates to:
  /// **'Android stores the private key in Keystore. Hardware protection depends on the device; attestation is not confirmed.'**
  String get card3_desc;

  /// No description provided for @btn_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btn_continue;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Confirms the file has not been changed since it was recorded. Does not assess what the recording shows.'**
  String get disclaimer;

  /// No description provided for @geo_note.
  ///
  /// In en, this message translates to:
  /// **'Location is as reported by the device.'**
  String get geo_note;

  /// No description provided for @recorded_by.
  ///
  /// In en, this message translates to:
  /// **'Recorded no later than: {time}'**
  String recorded_by(String time);

  /// No description provided for @verify_ok.
  ///
  /// In en, this message translates to:
  /// **'The file matches the recorded one. Unchanged since {time}.'**
  String verify_ok(String time);

  /// No description provided for @verify_fail.
  ///
  /// In en, this message translates to:
  /// **'The file differs from the recorded one.'**
  String get verify_fail;

  /// No description provided for @testnet_note.
  ///
  /// In en, this message translates to:
  /// **'(test network)'**
  String get testnet_note;

  /// No description provided for @nav_capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get nav_capture;

  /// No description provided for @nav_records.
  ///
  /// In en, this message translates to:
  /// **'My Records'**
  String get nav_records;

  /// No description provided for @nav_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get nav_verify;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @mode_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mode_photo;

  /// No description provided for @mode_video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mode_video;

  /// No description provided for @mode_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get mode_audio;

  /// No description provided for @capture_footer_note.
  ///
  /// In en, this message translates to:
  /// **'Captured in app. Gallery upload is disabled.'**
  String get capture_footer_note;

  /// No description provided for @no_connection_note.
  ///
  /// In en, this message translates to:
  /// **'offline: saving locally'**
  String get no_connection_note;

  /// No description provided for @status_on_device.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get status_on_device;

  /// No description provided for @status_queued.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get status_queued;

  /// No description provided for @status_anchored.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get status_anchored;

  /// No description provided for @status_simulated.
  ///
  /// In en, this message translates to:
  /// **'Test record'**
  String get status_simulated;

  /// No description provided for @file_upload_policy.
  ///
  /// In en, this message translates to:
  /// **'File Upload'**
  String get file_upload_policy;

  /// No description provided for @file_upload_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get file_upload_manual;

  /// No description provided for @file_upload_wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Only'**
  String get file_upload_wifi;

  /// No description provided for @file_upload_desc.
  ///
  /// In en, this message translates to:
  /// **'Hash digest is always sent, media file goes to independent vault only if permitted.'**
  String get file_upload_desc;

  /// No description provided for @record_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Record Details'**
  String get record_detail_title;

  /// No description provided for @device_attestation_title.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device_attestation_title;

  /// No description provided for @attestation_not_verified.
  ///
  /// In en, this message translates to:
  /// **'attestation unconfirmed'**
  String get attestation_not_verified;

  /// No description provided for @btn_share_cert.
  ///
  /// In en, this message translates to:
  /// **'Share Certificate (PDF)'**
  String get btn_share_cert;

  /// No description provided for @btn_share_receipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt (.mdfp.json)'**
  String get btn_share_receipt;

  /// No description provided for @btn_send_file_vault.
  ///
  /// In en, this message translates to:
  /// **'Send file to independent vault'**
  String get btn_send_file_vault;

  /// No description provided for @btn_select_file.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get btn_select_file;

  /// No description provided for @btn_scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get btn_scan_qr;

  /// No description provided for @tech_info_title.
  ///
  /// In en, this message translates to:
  /// **'Show Technical Information'**
  String get tech_info_title;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settings_language;

  /// No description provided for @btn_purge_data.
  ///
  /// In en, this message translates to:
  /// **'Purge Local Data'**
  String get btn_purge_data;

  /// No description provided for @purge_confirm_desc.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes local files, including any not yet uploaded. Server copies are not deleted. Solana Devnet is a test network and records may be reset.'**
  String get purge_confirm_desc;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get app_version;

  /// No description provided for @perm_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera: to capture evidence within the app.'**
  String get perm_camera;

  /// No description provided for @perm_mic.
  ///
  /// In en, this message translates to:
  /// **'Microphone: for video and audio recording of events.'**
  String get perm_mic;

  /// No description provided for @perm_location.
  ///
  /// In en, this message translates to:
  /// **'Location: records device coordinates (optional).'**
  String get perm_location;

  /// No description provided for @file_unchanged_header.
  ///
  /// In en, this message translates to:
  /// **'FILE UNCHANGED'**
  String get file_unchanged_header;

  /// No description provided for @finish_recording.
  ///
  /// In en, this message translates to:
  /// **'Finish recording first.'**
  String get finish_recording;

  /// No description provided for @settings_error.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings. Please try again.'**
  String get settings_error;

  /// No description provided for @storage_error.
  ///
  /// In en, this message translates to:
  /// **'Could not read saved records. Please try again.'**
  String get storage_error;

  /// No description provided for @camera_permission.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Android settings.'**
  String get camera_permission;

  /// No description provided for @microphone_permission.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access in Android settings.'**
  String get microphone_permission;

  /// No description provided for @camera_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable. Try reconnecting.'**
  String get camera_unavailable;

  /// No description provided for @audio_not_saved.
  ///
  /// In en, this message translates to:
  /// **'Could not save the audio recording.'**
  String get audio_not_saved;

  /// No description provided for @capture_error.
  ///
  /// In en, this message translates to:
  /// **'Could not record or save the file. Check permissions and free space, then retry.'**
  String get capture_error;

  /// No description provided for @device_registration_required.
  ///
  /// In en, this message translates to:
  /// **'An internet connection is required for initial device registration. Please retry.'**
  String get device_registration_required;

  /// No description provided for @capture_saved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved and signed. See My Records for upload status.'**
  String get capture_saved;

  /// No description provided for @capture_network_note.
  ///
  /// In en, this message translates to:
  /// **'Solana Devnet • GPS included when available'**
  String get capture_network_note;

  /// No description provided for @connect_camera.
  ///
  /// In en, this message translates to:
  /// **'Connect device and camera'**
  String get connect_camera;

  /// No description provided for @start_capture.
  ///
  /// In en, this message translates to:
  /// **'Capture / start recording'**
  String get start_capture;

  /// No description provided for @stop_capture.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stop_capture;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @records_empty.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get records_empty;

  /// No description provided for @status_failed.
  ///
  /// In en, this message translates to:
  /// **'Waiting to retry'**
  String get status_failed;

  /// No description provided for @status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get status_unknown;

  /// No description provided for @vault_pending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get vault_pending;

  /// No description provided for @vault_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get vault_uploaded;

  /// No description provided for @status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status_label;

  /// No description provided for @bytes.
  ///
  /// In en, this message translates to:
  /// **'{count} bytes'**
  String bytes(String count);

  /// No description provided for @file_label.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file_label;

  /// No description provided for @signature_label.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature_label;

  /// No description provided for @size_label.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size_label;

  /// No description provided for @gps_missing.
  ///
  /// In en, this message translates to:
  /// **'GPS: not available'**
  String get gps_missing;

  /// No description provided for @gps_coordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS: {lat}, {lon} ±{accuracy} m'**
  String gps_coordinates(String lat, String lon, String accuracy);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @block_time.
  ///
  /// In en, this message translates to:
  /// **'Block time'**
  String get block_time;

  /// No description provided for @public_digest.
  ///
  /// In en, this message translates to:
  /// **'Public record digest (for inclusion verification):'**
  String get public_digest;

  /// No description provided for @copy_digest.
  ///
  /// In en, this message translates to:
  /// **'Copy digest'**
  String get copy_digest;

  /// No description provided for @copy_success.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get copy_success;

  /// No description provided for @copy_error.
  ///
  /// In en, this message translates to:
  /// **'Could not copy to clipboard.'**
  String get copy_error;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get uploading;

  /// No description provided for @upload_file.
  ///
  /// In en, this message translates to:
  /// **'Upload file to Vault'**
  String get upload_file;

  /// No description provided for @copy_receipt.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON receipt'**
  String get copy_receipt;

  /// No description provided for @share_original.
  ///
  /// In en, this message translates to:
  /// **'Share original file'**
  String get share_original;

  /// No description provided for @record_not_sent.
  ///
  /// In en, this message translates to:
  /// **'Wait until the record is registered on the server.'**
  String get record_not_sent;

  /// No description provided for @receipt_not_ready.
  ///
  /// In en, this message translates to:
  /// **'Receipt is not ready. Retry after blockchain confirmation.'**
  String get receipt_not_ready;

  /// No description provided for @receipt_copied.
  ///
  /// In en, this message translates to:
  /// **'Receipt copied. Paste it at verify.digitaltrust.living together with the file. It contains recording metadata.'**
  String get receipt_copied;

  /// No description provided for @receipt_error.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve the receipt. Check your connection and retry.'**
  String get receipt_error;

  /// No description provided for @share_error.
  ///
  /// In en, this message translates to:
  /// **'Could not share the file. Check that the original is still on this device.'**
  String get share_error;

  /// No description provided for @upload_success.
  ///
  /// In en, this message translates to:
  /// **'File uploaded to Vault.'**
  String get upload_success;

  /// No description provided for @upload_error.
  ///
  /// In en, this message translates to:
  /// **'Vault did not accept the file. Check your connection and retry.'**
  String get upload_error;

  /// No description provided for @devnet_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Solana Devnet is a test network. Signatures and hashes do not prove the truth of the content.'**
  String get devnet_disclaimer;

  /// No description provided for @verify_title.
  ///
  /// In en, this message translates to:
  /// **'Integrity check'**
  String get verify_title;

  /// No description provided for @verify_help.
  ///
  /// In en, this message translates to:
  /// **'Select a saved record to check its SHA-256 hash.'**
  String get verify_help;

  /// No description provided for @verify_empty.
  ///
  /// In en, this message translates to:
  /// **'No local files to verify.'**
  String get verify_empty;

  /// No description provided for @verify_local_ok.
  ///
  /// In en, this message translates to:
  /// **'SHA-256, file size and record digest match. This is a local integrity check; the device signature and blockchain transaction are not checked here.'**
  String get verify_local_ok;

  /// No description provided for @verify_local_fail.
  ///
  /// In en, this message translates to:
  /// **'File or record changed: integrity check failed.'**
  String get verify_local_fail;

  /// No description provided for @verify_error.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the file. Check that the original is still on this device.'**
  String get verify_error;

  /// No description provided for @file_upload_any.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi and mobile data (4G/5G)'**
  String get file_upload_any;

  /// No description provided for @upload_any_desc.
  ///
  /// In en, this message translates to:
  /// **'Automatically upload files on any connection. Uses your mobile data allowance.'**
  String get upload_any_desc;

  /// No description provided for @upload_wifi_desc.
  ///
  /// In en, this message translates to:
  /// **'Automatically upload media only on an unmetered connection (usually Wi-Fi).'**
  String get upload_wifi_desc;

  /// No description provided for @upload_manual_desc.
  ///
  /// In en, this message translates to:
  /// **'Upload media only when you press the button in record details.'**
  String get upload_manual_desc;

  /// No description provided for @security_section.
  ///
  /// In en, this message translates to:
  /// **'Security and local data'**
  String get security_section;

  /// No description provided for @delete_device.
  ///
  /// In en, this message translates to:
  /// **'Delete from device'**
  String get delete_device;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get about;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'NGO Center for Digital Trust'**
  String get organization;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @key_protection.
  ///
  /// In en, this message translates to:
  /// **'Key protection'**
  String get key_protection;

  /// No description provided for @keystore_unverified.
  ///
  /// In en, this message translates to:
  /// **'Android Keystore (attestation unconfirmed)'**
  String get keystore_unverified;

  /// No description provided for @software_test.
  ///
  /// In en, this message translates to:
  /// **'Software key (test mode)'**
  String get software_test;

  /// No description provided for @server_label.
  ///
  /// In en, this message translates to:
  /// **'Registration server'**
  String get server_label;

  /// No description provided for @network_label.
  ///
  /// In en, this message translates to:
  /// **'Blockchain network'**
  String get network_label;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @purge_title.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data?'**
  String get purge_title;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete_all.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get delete_all;

  /// No description provided for @purge_error.
  ///
  /// In en, this message translates to:
  /// **'Could not delete all local data. Please try again.'**
  String get purge_error;

  /// No description provided for @purge_success.
  ///
  /// In en, this message translates to:
  /// **'Local files deleted from this device.'**
  String get purge_success;

  /// No description provided for @developed_by.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developed_by;
}

class _AppLocalizationsGeneratedDelegate extends LocalizationsDelegate<AppLocalizationsGenerated> {
  const _AppLocalizationsGeneratedDelegate();

  @override
  Future<AppLocalizationsGenerated> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsGenerated>(lookupAppLocalizationsGenerated(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ja', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsGeneratedDelegate old) => false;
}

AppLocalizationsGenerated lookupAppLocalizationsGenerated(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsGeneratedEn();
    case 'es': return AppLocalizationsGeneratedEs();
    case 'ja': return AppLocalizationsGeneratedJa();
    case 'ru': return AppLocalizationsGeneratedRu();
    case 'uk': return AppLocalizationsGeneratedUk();
  }

  throw FlutterError(
    'AppLocalizationsGenerated.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

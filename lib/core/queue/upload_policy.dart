import 'package:shared_preferences/shared_preferences.dart';

/// Shared by foreground UI and background isolates so their policy agrees.
class UploadPolicy {
  static const values = ['any', 'wifi', 'manual'];

  static Future<String> load() async {
    // Upgrade the old Wi-Fi default once; preserve an explicit manual choice.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var policy = prefs.getString('file_upload_policy');
    if (prefs.getBool('upload_policy_v2') != true) {
      policy = policy == 'manual' ? 'manual' : 'any';
      await save(policy);
    }
    return values.contains(policy) ? policy! : 'manual';
  }

  static Future<void> save(String value) async {
    // Fail closed if persistence fails instead of silently changing consent.
    if (!values.contains(value)) throw ArgumentError.value(value);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('file_upload_policy', value) ||
        !await prefs.setBool('upload_policy_v2', true)) {
      throw StateError('Could not persist upload policy');
    }
  }

  static bool allows(String policy, {required bool unmetered}) {
    // Connected workers include cellular; the Wi-Fi worker is unmetered only.
    return policy == 'any' || (policy == 'wifi' && unmetered);
  }
}

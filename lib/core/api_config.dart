/// Shared endpoints for foreground and background isolates.
class ApiConfig {
  static const api = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.digitaltrust.living');
  static const vault = String.fromEnvironment('VAULT_BASE_URL',
      defaultValue: 'https://api.digitaltrust.living/vault');
}

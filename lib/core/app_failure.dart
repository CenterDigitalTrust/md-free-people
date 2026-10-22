/// Carries a translation key without exposing raw platform errors to users.
class AppFailure implements Exception {
  final String key;
  const AppFailure(this.key);
  @override
  String toString() => key;
}

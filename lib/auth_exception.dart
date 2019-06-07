class AuthException implements Exception {
  final String msg;

  const AuthException([this.msg]);

  @override
  String toString() => "AuthException: $msg" ?? "Invalid secret";
}

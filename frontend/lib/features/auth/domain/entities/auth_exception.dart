class AuthRegistrationRequiredException implements Exception {
  const AuthRegistrationRequiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  const SignUpWithEmailPassword(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

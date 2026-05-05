import '../repositories/auth_repository.dart';

class SendPasswordResetEmail {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}

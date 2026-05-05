import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> watchAuthState();
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });
  Future<AuthUser?> loginWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<AuthUser> syncUserProfile(AuthUser user);
  Future<void> logout();
}

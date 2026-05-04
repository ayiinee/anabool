import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> loginWithGoogle();
  Future<AuthUser> syncUserProfile(AuthUser user);
  Future<void> logout();
}

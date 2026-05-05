import '../../domain/entities/auth_user.dart';
import '../../domain/entities/auth_sync_mode.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Stream<AuthUser?> watchAuthState() {
    return _remoteDatasource.watchAuthState();
  }

  @override
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _remoteDatasource.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _remoteDatasource.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<AuthUser?> loginWithGoogle() {
    return _remoteDatasource.loginWithGoogle();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remoteDatasource.sendPasswordResetEmail(email);
  }

  @override
  Future<AuthUser> syncUserProfile(
    AuthUser user, {
    required AuthSyncMode mode,
  }) {
    return _remoteDatasource.syncUserProfile(
      AuthUserModel.fromEntity(user),
      mode: mode,
    );
  }

  @override
  Future<void> logout() {
    return _remoteDatasource.logout();
  }
}

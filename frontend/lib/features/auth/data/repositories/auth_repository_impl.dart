import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<AuthUser?> loginWithGoogle() {
    return _remoteDatasource.loginWithGoogle();
  }

  @override
  Future<AuthUser> syncUserProfile(AuthUser user) {
    return _remoteDatasource.syncUserProfile(AuthUserModel.fromEntity(user));
  }

  @override
  Future<void> logout() {
    return _remoteDatasource.logout();
  }
}

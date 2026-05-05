import '../entities/auth_user.dart';
import '../entities/auth_sync_mode.dart';
import '../repositories/auth_repository.dart';

class SyncUserProfile {
  const SyncUserProfile(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call(
    AuthUser user, {
    required AuthSyncMode mode,
  }) {
    return _repository.syncUserProfile(user, mode: mode);
  }
}

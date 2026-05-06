import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateSafetyMode {
  const UpdateSafetyMode(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call(bool enabled) {
    return _repository.updateSafetyMode(enabled);
  }
}

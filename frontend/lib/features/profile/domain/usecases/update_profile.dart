import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}

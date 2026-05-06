import '../entities/user_address.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class ManageAddress {
  const ManageAddress(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> save(UserAddress address) {
    return _repository.saveAddress(address);
  }

  Future<UserProfile> delete(String addressId) {
    return _repository.deleteAddress(addressId);
  }
}

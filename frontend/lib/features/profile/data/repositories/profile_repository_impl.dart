import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ProfileRemoteDatasource _remoteDatasource;

  @override
  Future<UserProfile> getProfile() {
    return _remoteDatasource.getProfile();
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) {
    return _remoteDatasource.updateProfile(profile);
  }

  @override
  Future<UserProfile> updateSafetyMode(bool enabled) {
    return _remoteDatasource.updateSafetyMode(enabled);
  }

  @override
  Future<UserProfile> saveAddress(UserAddress address) {
    return _remoteDatasource.saveAddress(address);
  }

  @override
  Future<UserProfile> deleteAddress(String addressId) {
    return _remoteDatasource.deleteAddress(addressId);
  }
}

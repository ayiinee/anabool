import '../entities/user_address.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile(UserProfile profile);

  Future<UserProfile> updateSafetyMode(bool enabled);

  Future<UserProfile> saveAddress(UserAddress address);

  Future<UserProfile> deleteAddress(String addressId);
}

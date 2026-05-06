import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/user_profile.dart';
import 'user_address_model.dart';

class PetProfileModel extends PetProfile {
  const PetProfileModel({
    required super.id,
    required super.name,
    required super.imageAsset,
    required super.defecateCount,
    required super.urinateCount,
  });

  factory PetProfileModel.fromMap(Map<String, dynamic> map) {
    return PetProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      imageAsset: map['image_asset'] as String,
      defecateCount: map['defecate_count'] as int,
      urinateCount: map['urinate_count'] as int,
    );
  }
}

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.avatarAsset,
    required super.location,
    required super.voucherCount,
    required super.meowPoints,
    required super.safetyModeEnabled,
    required super.addresses,
    required super.pets,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phone_number'] as String,
      avatarAsset: map['avatar_asset'] as String? ?? HomeAssets.profilePhoto,
      location: map['location'] as String,
      voucherCount: map['voucher_count'] as int,
      meowPoints: map['meow_points'] as int,
      safetyModeEnabled: map['safety_mode_enabled'] as bool? ?? true,
      addresses: (map['addresses'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(UserAddressModel.fromMap)
          .toList(),
      pets: (map['pets'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PetProfileModel.fromMap)
          .toList(),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      avatarAsset: profile.avatarAsset,
      location: profile.location,
      voucherCount: profile.voucherCount,
      meowPoints: profile.meowPoints,
      safetyModeEnabled: profile.safetyModeEnabled,
      addresses: profile.addresses,
      pets: profile.pets,
    );
  }
}

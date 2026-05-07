import '../../../../core/auth/current_user_identity.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_address_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile(UserProfile profile);

  Future<UserProfile> updateSafetyMode(bool enabled);

  Future<UserProfile> saveAddress(UserAddress address);

  Future<UserProfile> deleteAddress(String addressId);
}

class LocalProfileRemoteDatasource implements ProfileRemoteDatasource {
  LocalProfileRemoteDatasource() : _profile = UserProfileModel.fromMap(_mock) {
    _syncCurrentUser();
  }

  UserProfile _profile;

  static final Map<String, dynamic> _mock = {
    'id': CurrentUserIdentity.fallbackUserId,
    'name': CurrentUserIdentity.fallbackName,
    'email': CurrentUserIdentity.fallbackEmail,
    'phone_number': '+62 812 4567 8901',
    'avatar_asset': HomeAssets.profilePhoto,
    'location': 'Bali, Indonesia',
    'voucher_count': 4,
    'meow_points': 194589,
    'safety_mode_enabled': true,
    'addresses': [
      {
        'id': 'address-home',
        'label': 'Rumah',
        'recipient_name': CurrentUserIdentity.fallbackName,
        'phone_number': '+62 812 4567 8901',
        'full_address': 'Jl. Tukad Yeh Aya No. 18, Renon',
        'city': 'Denpasar',
        'province': 'Bali',
        'postal_code': '80226',
        'is_primary': true,
      },
    ],
    'pets': [
      {
        'id': 'gamora',
        'name': 'Gamora',
        'image_asset': HomeAssets.gamoraCat,
        'defecate_count': 2,
        'urinate_count': 4,
      },
      {
        'id': 'charlotte',
        'name': 'Charlotte',
        'image_asset': HomeAssets.charlotteCat,
        'defecate_count': 2,
        'urinate_count': 4,
      },
    ],
  };

  @override
  Future<UserProfile> getProfile() async {
    _syncCurrentUser();
    return _profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await CurrentUserIdentity.updateDisplayName(profile.name);
    _profile = UserProfileModel.fromEntity(profile);
    return _profile;
  }

  @override
  Future<UserProfile> updateSafetyMode(bool enabled) async {
    _profile = _profile.copyWith(safetyModeEnabled: enabled);
    return _profile;
  }

  @override
  Future<UserProfile> saveAddress(UserAddress address) async {
    final nextAddress = UserAddressModel.fromEntity(address);
    final addresses = [
      for (final current in _profile.addresses)
        if (current.id != nextAddress.id)
          current.copyWith(isPrimary: nextAddress.isPrimary ? false : null),
      nextAddress,
    ];

    _profile = _profile.copyWith(addresses: addresses);
    return _profile;
  }

  @override
  Future<UserProfile> deleteAddress(String addressId) async {
    final addresses = [
      for (final address in _profile.addresses)
        if (address.id != addressId) address,
    ];
    _profile = _profile.copyWith(addresses: addresses);
    return _profile;
  }

  void _syncCurrentUser() {
    final userName = CurrentUserIdentity.displayName(fallback: _profile.name);
    final email = CurrentUserIdentity.email(fallback: _profile.email);
    final userId = CurrentUserIdentity.userId(fallback: _profile.id);

    _profile = _profile.copyWith(
      id: userId,
      name: userName,
      email: email,
      addresses: [
        for (final address in _profile.addresses)
          address.isPrimary ? address.copyWith(recipientName: userName) : address,
      ],
    );
  }
}

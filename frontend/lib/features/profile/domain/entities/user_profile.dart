import 'user_address.dart';

class PetProfile {
  const PetProfile({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.defecateCount,
    required this.urinateCount,
  });

  final String id;
  final String name;
  final String imageAsset;
  final int defecateCount;
  final int urinateCount;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.avatarAsset,
    required this.location,
    required this.voucherCount,
    required this.meowPoints,
    required this.safetyModeEnabled,
    required this.addresses,
    required this.pets,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String avatarAsset;
  final String location;
  final int voucherCount;
  final int meowPoints;
  final bool safetyModeEnabled;
  final List<UserAddress> addresses;
  final List<PetProfile> pets;

  UserAddress? get primaryAddress {
    for (final address in addresses) {
      if (address.isPrimary) {
        return address;
      }
    }

    return addresses.isNotEmpty ? addresses.first : null;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarAsset,
    String? location,
    int? voucherCount,
    int? meowPoints,
    bool? safetyModeEnabled,
    List<UserAddress>? addresses,
    List<PetProfile>? pets,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      location: location ?? this.location,
      voucherCount: voucherCount ?? this.voucherCount,
      meowPoints: meowPoints ?? this.meowPoints,
      safetyModeEnabled: safetyModeEnabled ?? this.safetyModeEnabled,
      addresses: addresses ?? this.addresses,
      pets: pets ?? this.pets,
    );
  }
}

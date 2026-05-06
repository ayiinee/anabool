import '../../domain/entities/user_address.dart';

class UserAddressModel extends UserAddress {
  const UserAddressModel({
    required super.id,
    required super.label,
    required super.recipientName,
    required super.phoneNumber,
    required super.fullAddress,
    required super.city,
    required super.province,
    required super.postalCode,
    super.isPrimary,
  });

  factory UserAddressModel.fromMap(Map<String, dynamic> map) {
    return UserAddressModel(
      id: map['id'] as String,
      label: map['label'] as String,
      recipientName: map['recipient_name'] as String,
      phoneNumber: map['phone_number'] as String,
      fullAddress: map['full_address'] as String,
      city: map['city'] as String,
      province: map['province'] as String,
      postalCode: map['postal_code'] as String,
      isPrimary: map['is_primary'] as bool? ?? false,
    );
  }

  factory UserAddressModel.fromEntity(UserAddress address) {
    return UserAddressModel(
      id: address.id,
      label: address.label,
      recipientName: address.recipientName,
      phoneNumber: address.phoneNumber,
      fullAddress: address.fullAddress,
      city: address.city,
      province: address.province,
      postalCode: address.postalCode,
      isPrimary: address.isPrimary,
    );
  }
}

class UserAddress {
  const UserAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.city,
    required this.province,
    required this.postalCode,
    this.isPrimary = false,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final String city;
  final String province;
  final String postalCode;
  final bool isPrimary;

  UserAddress copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? fullAddress,
    String? city,
    String? province,
    String? postalCode,
    bool? isPrimary,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

import '../../domain/entities/litter_box.dart';

class LitterBoxModel extends LitterBox {
  const LitterBoxModel({
    required super.id,
    required super.userId,
    required super.catId,
    required super.locationLabel,
    required super.boxType,
    required super.litterType,
    required super.boxCount,
    required super.cleaningFrequency,
    required super.lastCleanedLabel,
    required super.status,
    required super.lastCleanedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LitterBoxModel.fromMap(Map<String, dynamic> map) {
    final lastCleaned = map['last_cleaned_at'];
    return LitterBoxModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      catId: map['cat_id'] as String,
      locationLabel: map['location_label'] as String? ?? '',
      boxType: map['box_type'] as String? ?? 'Bak terbuka',
      litterType: map['litter_type'] as String? ?? 'Bentonite/Pasir Gumpal',
      boxCount: map['box_count'] as int? ?? 1,
      cleaningFrequency:
          map['cleaning_frequency'] as String? ?? 'Sekali sehari',
      lastCleanedLabel: map['last_cleaned_label'] as String? ?? 'Hari ini',
      status: map['status'] as String? ?? 'Normal',
      lastCleanedAt:
          lastCleaned is String ? DateTime.tryParse(lastCleaned) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  factory LitterBoxModel.fromEntity(LitterBox litterBox) {
    return LitterBoxModel(
      id: litterBox.id,
      userId: litterBox.userId,
      catId: litterBox.catId,
      locationLabel: litterBox.locationLabel,
      boxType: litterBox.boxType,
      litterType: litterBox.litterType,
      boxCount: litterBox.boxCount,
      cleaningFrequency: litterBox.cleaningFrequency,
      lastCleanedLabel: litterBox.lastCleanedLabel,
      status: litterBox.status,
      lastCleanedAt: litterBox.lastCleanedAt,
      createdAt: litterBox.createdAt,
      updatedAt: litterBox.updatedAt,
    );
  }
}

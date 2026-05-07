import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/cat.dart';

class CatModel extends Cat {
  const CatModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.breed,
    required super.lifeStage,
    required super.gender,
    required super.avatarAsset,
    required super.peeFrequencyPerDay,
    required super.poopFrequencyPerDay,
    required super.healthNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CatModel.fromMap(Map<String, dynamic> map) {
    return CatModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String? ?? '',
      lifeStage: map['life_stage'] as String? ?? 'Dewasa',
      gender: map['gender'] as String? ?? 'Belum diisi',
      avatarAsset:
          map['avatar_asset'] as String? ?? CatAssets.personalizationMascot,
      peeFrequencyPerDay: map['pee_frequency_per_day'] as int? ?? 0,
      poopFrequencyPerDay: map['poop_frequency_per_day'] as int? ?? 0,
      healthNotes: map['health_notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  factory CatModel.fromEntity(Cat cat) {
    return CatModel(
      id: cat.id,
      ownerId: cat.ownerId,
      name: cat.name,
      breed: cat.breed,
      lifeStage: cat.lifeStage,
      gender: cat.gender,
      avatarAsset: cat.avatarAsset,
      peeFrequencyPerDay: cat.peeFrequencyPerDay,
      poopFrequencyPerDay: cat.poopFrequencyPerDay,
      healthNotes: cat.healthNotes,
      createdAt: cat.createdAt,
      updatedAt: cat.updatedAt,
    );
  }
}

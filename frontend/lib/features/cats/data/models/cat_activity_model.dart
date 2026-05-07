import '../../domain/entities/cat_activity.dart';

class CatActivityModel extends CatActivity {
  const CatActivityModel({
    required super.id,
    required super.catId,
    required super.litterBoxId,
    required super.type,
    required super.notes,
    required super.recordedAt,
    required super.createdAt,
  });

  factory CatActivityModel.fromMap(Map<String, dynamic> map) {
    return CatActivityModel(
      id: map['id'] as String,
      catId: map['cat_id'] as String,
      litterBoxId: map['litter_box_id'] as String?,
      type: _typeFromString(map['type'] as String?),
      notes: map['notes'] as String? ?? '',
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  factory CatActivityModel.fromEntity(CatActivity activity) {
    return CatActivityModel(
      id: activity.id,
      catId: activity.catId,
      litterBoxId: activity.litterBoxId,
      type: activity.type,
      notes: activity.notes,
      recordedAt: activity.recordedAt,
      createdAt: activity.createdAt,
    );
  }

  static CatActivityType _typeFromString(String? value) {
    switch (value) {
      case 'pee':
        return CatActivityType.pee;
      case 'poop':
        return CatActivityType.poop;
      case 'clean':
        return CatActivityType.clean;
      default:
        return CatActivityType.note;
    }
  }
}

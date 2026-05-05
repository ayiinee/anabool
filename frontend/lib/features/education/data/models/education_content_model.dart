import '../../domain/entities/education_content.dart';

class EducationContentModel extends EducationContent {
  const EducationContentModel({
    required super.id,
    required super.categoryId,
    required super.categorySlug,
    required super.title,
    required super.summary,
    required super.body,
    required super.thumbnailAsset,
    required super.rewardPoints,
    required super.durationMinutes,
    super.isFeatured,
  });

  factory EducationContentModel.fromMap(Map<String, dynamic> map) {
    final rewardPoints = map['reward_points'] ?? map['meowpoints_reward'] ?? 0;
    final durationMinutes =
        map['duration_minutes'] ?? map['estimated_duration_minutes'] ?? 0;

    return EducationContentModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      categorySlug: map['category_slug'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      body: map['body'] as String,
      thumbnailAsset:
          (map['thumbnail_asset'] ?? map['thumbnail_url'] ?? '') as String,
      rewardPoints: (rewardPoints as num).toInt(),
      durationMinutes: (durationMinutes as num).toInt(),
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }
}

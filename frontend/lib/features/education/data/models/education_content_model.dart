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
    return EducationContentModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      categorySlug: map['category_slug'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      body: map['body'] as String,
      thumbnailAsset: map['thumbnail_asset'] as String,
      rewardPoints: map['reward_points'] as int,
      durationMinutes: map['duration_minutes'] as int,
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }
}

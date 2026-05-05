class EducationContent {
  const EducationContent({
    required this.id,
    required this.categoryId,
    required this.categorySlug,
    required this.title,
    required this.summary,
    required this.body,
    required this.thumbnailAsset,
    required this.rewardPoints,
    required this.durationMinutes,
    this.isFeatured = false,
  });

  final String id;
  final String categoryId;
  final String categorySlug;
  final String title;
  final String summary;
  final String body;
  final String thumbnailAsset;
  final int rewardPoints;
  final int durationMinutes;
  final bool isFeatured;
}

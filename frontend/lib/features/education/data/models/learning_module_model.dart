import '../../domain/entities/learning_module.dart';

class LearningModuleModel extends LearningModule {
  const LearningModuleModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.slug,
    required super.category,
    required super.categoryLabel,
    required super.level,
    required super.language,
    required super.xpReward,
    required super.totalLessons,
    required super.estimatedDurationMinutes,
    required super.isPublished,
    required super.sourceType,
    required super.pdfAsset,
    required super.thumbnailAsset,
    required super.summary,
    required super.hero,
    required super.learningGoals,
    required super.lessons,
    required super.completion,
    required super.chatbotCta,
    required super.pdfViewerCta,
    required super.references,
  });

  factory LearningModuleModel.fromMap(Map<String, dynamic> map) {
    return LearningModuleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      slug: map['slug'] as String,
      category: map['category'] as String,
      categoryLabel: map['categoryLabel'] as String? ?? '',
      level: map['level'] as String? ?? 'basic',
      language: map['language'] as String? ?? 'id',
      xpReward: map['xpReward'] as int? ?? 0,
      totalLessons: map['totalLessons'] as int? ?? 0,
      estimatedDurationMinutes: map['estimatedDurationMinutes'] as int? ?? 0,
      isPublished: map['isPublished'] as bool? ?? true,
      sourceType: map['sourceType'] as String? ?? 'json',
      pdfAsset: map['pdfAsset'] as String?,
      thumbnailAsset: map['thumbnailAsset'] as String,
      summary: map['summary'] as String,
      hero: _heroFromMap(map['hero'] as Map<String, dynamic>?),
      learningGoals: _stringList(map['learningGoals'] as List<dynamic>?),
      lessons: (map['lessons'] as List<dynamic>? ?? const [])
          .map((item) => _lessonFromMap(item as Map<String, dynamic>))
          .toList(),
      completion: _completionFromMap(
        map['completion'] as Map<String, dynamic>?,
      ),
      chatbotCta: _ctaFromMap(map['chatbotCta'] as Map<String, dynamic>?),
      pdfViewerCta: _ctaFromMap(map['pdfViewerCta'] as Map<String, dynamic>?),
      references: _stringList(map['references'] as List<dynamic>?),
    );
  }

  static ModuleHero _heroFromMap(Map<String, dynamic>? map) {
    return ModuleHero(
      title: map?['title'] as String? ?? '',
      description: map?['description'] as String? ?? '',
      badgeText: map?['badgeText'] as String? ?? '',
      safetyLevel: map?['safetyLevel'] as String? ?? '',
    );
  }

  static ModuleLesson _lessonFromMap(Map<String, dynamic> map) {
    return ModuleLesson(
      id: map['id'] as String,
      order: map['order'] as int,
      title: map['title'] as String,
      shortTitle: map['shortTitle'] as String? ?? map['title'] as String,
      type: map['type'] as String? ?? 'reading',
      estimatedReadMinutes: map['estimatedReadMinutes'] as int? ?? 1,
      xpReward: map['xpReward'] as int? ?? 0,
      paragraphs: _stringList(map['paragraphs'] as List<dynamic>?),
      safetyNote: map['safetyNote'] as String?,
      keyTakeaway: map['keyTakeaway'] as String? ?? '',
      ctaLabel: map['ctaLabel'] as String? ?? 'Selanjutnya',
    );
  }

  static ModuleCompletion _completionFromMap(Map<String, dynamic>? map) {
    return ModuleCompletion(
      title: map?['title'] as String? ?? 'Modul selesai!',
      message: map?['message'] as String? ?? '',
      rewardText: map?['rewardText'] as String? ?? '',
      buttonLabel: map?['buttonLabel'] as String? ?? 'Kembali ke Modul',
    );
  }

  static ModuleCta _ctaFromMap(Map<String, dynamic>? map) {
    return ModuleCta(
      title: map?['title'] as String? ?? '',
      description: map?['description'] as String? ?? '',
      buttonLabel: map?['buttonLabel'] as String? ?? '',
      url: map?['url'] as String? ??
          map?['pdfUrl'] as String? ??
          map?['pdf_url'] as String? ??
          map?['driveUrl'] as String? ??
          map?['drive_url'] as String? ??
          map?['googleDriveUrl'] as String? ??
          map?['google_drive_url'] as String?,
    );
  }

  static List<String> _stringList(List<dynamic>? values) {
    return (values ?? const []).map((item) => item as String).toList();
  }
}

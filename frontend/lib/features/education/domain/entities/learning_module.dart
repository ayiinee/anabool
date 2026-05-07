class LearningModule {
  const LearningModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.slug,
    required this.category,
    required this.categoryLabel,
    required this.level,
    required this.language,
    required this.xpReward,
    required this.totalLessons,
    required this.estimatedDurationMinutes,
    required this.isPublished,
    required this.sourceType,
    required this.pdfAsset,
    required this.thumbnailAsset,
    required this.summary,
    required this.hero,
    required this.learningGoals,
    required this.lessons,
    required this.completion,
    required this.chatbotCta,
    required this.pdfViewerCta,
    required this.references,
  });

  final String id;
  final String title;
  final String subtitle;
  final String slug;
  final String category;
  final String categoryLabel;
  final String level;
  final String language;
  final int xpReward;
  final int totalLessons;
  final int estimatedDurationMinutes;
  final bool isPublished;
  final String sourceType;
  final String? pdfAsset;
  final String thumbnailAsset;
  final String summary;
  final ModuleHero hero;
  final List<String> learningGoals;
  final List<ModuleLesson> lessons;
  final ModuleCompletion completion;
  final ModuleCta chatbotCta;
  final ModuleCta pdfViewerCta;
  final List<String> references;

  ModuleLesson lessonAt(int index) {
    return lessons[index.clamp(0, lessons.length - 1).toInt()];
  }
}

class ModuleHero {
  const ModuleHero({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.safetyLevel,
  });

  final String title;
  final String description;
  final String badgeText;
  final String safetyLevel;
}

class ModuleLesson {
  const ModuleLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.shortTitle,
    required this.type,
    required this.estimatedReadMinutes,
    required this.xpReward,
    required this.paragraphs,
    required this.safetyNote,
    required this.keyTakeaway,
    required this.ctaLabel,
  });

  final String id;
  final int order;
  final String title;
  final String shortTitle;
  final String type;
  final int estimatedReadMinutes;
  final int xpReward;
  final List<String> paragraphs;
  final String? safetyNote;
  final String keyTakeaway;
  final String ctaLabel;
}

class ModuleCompletion {
  const ModuleCompletion({
    required this.title,
    required this.message,
    required this.rewardText,
    required this.buttonLabel,
  });

  final String title;
  final String message;
  final String rewardText;
  final String buttonLabel;
}

class ModuleCta {
  const ModuleCta({
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.url,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final String? url;
}

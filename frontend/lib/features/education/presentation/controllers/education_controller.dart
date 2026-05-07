import 'package:flutter/foundation.dart';

import '../../data/datasources/education_remote_datasource.dart';
import '../../data/repositories/education_repository_impl.dart';
import '../../domain/entities/education_category.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_module.dart';
import '../../domain/entities/user_edu_progress.dart';
import '../../domain/repositories/education_repository.dart';
import '../../domain/usecases/complete_education_content.dart';
import '../../domain/usecases/complete_learning_lesson.dart';
import '../../domain/usecases/get_education_contents.dart';
import '../../domain/usecases/get_education_detail.dart';
import '../../domain/usecases/get_learning_module.dart';

class EducationController extends ChangeNotifier {
  EducationController({
    required GetEducationContents getEducationContents,
    required GetEducationDetail getEducationDetail,
    required GetLearningModule getLearningModule,
    required CompleteEducationContent completeEducationContent,
    required CompleteLearningLesson completeLearningLesson,
  })  : _getEducationContents = getEducationContents,
        _getEducationDetail = getEducationDetail,
        _getLearningModule = getLearningModule,
        _completeEducationContent = completeEducationContent,
        _completeLearningLesson = completeLearningLesson;

  factory EducationController.create() {
    final repository = _sharedRepository;
    return EducationController(
      getEducationContents: GetEducationContents(repository),
      getEducationDetail: GetEducationDetail(repository),
      getLearningModule: GetLearningModule(repository),
      completeEducationContent: CompleteEducationContent(repository),
      completeLearningLesson: CompleteLearningLesson(repository),
    );
  }

  static final EducationRepository _sharedRepository = EducationRepositoryImpl(
    remoteDatasource: LocalEducationRemoteDatasource(),
  );

  final GetEducationContents _getEducationContents;
  final GetEducationDetail _getEducationDetail;
  final GetLearningModule _getLearningModule;
  final CompleteEducationContent _completeEducationContent;
  final CompleteLearningLesson _completeLearningLesson;

  bool isLoading = false;
  bool isCompleting = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategorySlug = 'all';

  List<EducationCategory> categories = const [];
  List<EducationContent> contents = const [];
  List<UserEduProgress> progress = const [];
  EducationContent? selectedContent;
  LearningModule? selectedModule;
  int currentLessonIndex = 0;

  List<EducationContent> get filteredContents {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    return contents.where((content) {
      final matchesCategory = selectedCategorySlug == 'all' ||
          content.categorySlug == selectedCategorySlug;
      final categoryName = categoryNameFor(content.categorySlug).toLowerCase();
      final matchesQuery = normalizedQuery.isEmpty ||
          content.title.toLowerCase().contains(normalizedQuery) ||
          content.summary.toLowerCase().contains(normalizedQuery) ||
          categoryName.contains(normalizedQuery) ||
          content.categorySlug.toLowerCase().contains(normalizedQuery);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<EducationContent> get inProgressContents {
    return contents.where((content) {
      final itemProgress = progressFor(content.id);
      return itemProgress.progressPct > 0 && !itemProgress.isCompleted;
    }).toList();
  }

  int get uncompletedCount {
    return contents
        .where((content) => !progressFor(content.id).isCompleted)
        .length;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final catalog = await _getEducationContents();
      categories = catalog.categories;
      contents = catalog.contents;
      progress = catalog.progress;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String contentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final catalog = await _getEducationContents();
      categories = catalog.categories;
      contents = catalog.contents;
      progress = catalog.progress;
      selectedContent = await _getEducationDetail(contentId);
      selectedModule = await _getLearningModule(contentId);
      currentLessonIndex = nextLessonIndexFor(selectedModule!.id);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> complete(String contentId) async {
    isCompleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final completed = await _completeEducationContent(contentId);
      progress = [
        for (final item in progress)
          if (item.contentId != completed.contentId) item,
        completed,
      ];
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isCompleting = false;
      notifyListeners();
    }
  }

  Future<bool> completeCurrentLesson() async {
    final module = selectedModule;
    if (module == null || module.lessons.isEmpty) {
      return false;
    }

    final lesson = module.lessonAt(currentLessonIndex);
    isCompleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _completeLearningLesson(module.id, lesson.id);
      progress = [
        for (final item in progress)
          if (item.contentId != updated.contentId) item,
        updated,
      ];

      if (!updated.isCompleted) {
        currentLessonIndex = nextLessonIndexFor(module.id);
      }

      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isCompleting = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void selectCategory(String slug) {
    selectedCategorySlug = slug;
    notifyListeners();
  }

  UserEduProgress progressFor(String contentId) {
    for (final item in progress) {
      if (item.contentId == contentId) {
        return item;
      }
    }

    return UserEduProgress(
      contentId: contentId,
      progressPct: 0,
      isCompleted: false,
    );
  }

  int completedLessonCountFor(String contentId) {
    final module = selectedModule;
    if (module == null || module.lessons.isEmpty) {
      return 0;
    }

    final pct = progressFor(contentId).progressPct.clamp(0, 100);
    return (pct / 100 * module.lessons.length).round().clamp(
          0,
          module.lessons.length,
        );
  }

  int nextLessonIndexFor(String contentId) {
    final module = selectedModule;
    if (module == null || module.lessons.isEmpty) {
      return 0;
    }

    final completedLessons = completedLessonCountFor(contentId);
    if (completedLessons >= module.lessons.length) {
      return module.lessons.length - 1;
    }

    return completedLessons;
  }

  void goToPreviousLesson() {
    if (currentLessonIndex == 0) {
      return;
    }

    currentLessonIndex -= 1;
    notifyListeners();
  }

  String categoryNameFor(String slug) {
    for (final category in categories) {
      if (category.slug == slug) {
        return category.name;
      }
    }

    return slug;
  }

  EducationContent? nextRecommendedAfter(String completedContentId) {
    for (final content in contents) {
      if (content.id != completedContentId &&
          !progressFor(content.id).isCompleted) {
        return content;
      }
    }

    for (final content in contents) {
      if (content.id != completedContentId) {
        return content;
      }
    }

    return null;
  }
}

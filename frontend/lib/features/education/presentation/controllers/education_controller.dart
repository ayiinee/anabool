import 'package:flutter/foundation.dart';

import '../../data/datasources/education_remote_datasource.dart';
import '../../data/repositories/education_repository_impl.dart';
import '../../domain/entities/education_category.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/user_edu_progress.dart';
import '../../domain/repositories/education_repository.dart';
import '../../domain/usecases/complete_education_content.dart';
import '../../domain/usecases/get_education_contents.dart';
import '../../domain/usecases/get_education_detail.dart';

class EducationController extends ChangeNotifier {
  EducationController({
    required GetEducationContents getEducationContents,
    required GetEducationDetail getEducationDetail,
    required CompleteEducationContent completeEducationContent,
  })  : _getEducationContents = getEducationContents,
        _getEducationDetail = getEducationDetail,
        _completeEducationContent = completeEducationContent;

  factory EducationController.create() {
    final repository = _sharedRepository;
    return EducationController(
      getEducationContents: GetEducationContents(repository),
      getEducationDetail: GetEducationDetail(repository),
      completeEducationContent: CompleteEducationContent(repository),
    );
  }

  static final EducationRepository _sharedRepository = EducationRepositoryImpl(
    remoteDatasource: LocalEducationRemoteDatasource(),
  );

  final GetEducationContents _getEducationContents;
  final GetEducationDetail _getEducationDetail;
  final CompleteEducationContent _completeEducationContent;

  bool isLoading = false;
  bool isCompleting = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategorySlug = 'all';

  List<EducationCategory> categories = const [];
  List<EducationContent> contents = const [];
  List<UserEduProgress> progress = const [];
  EducationContent? selectedContent;

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
      selectedContent = await _getEducationDetail(contentId);
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

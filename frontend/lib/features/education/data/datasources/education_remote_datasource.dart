import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/constants/asset_constants.dart';
import '../models/education_category_model.dart';
import '../models/education_content_model.dart';
import '../models/learning_module_model.dart';
import '../models/user_edu_progress_model.dart';

abstract class EducationRemoteDatasource {
  Future<List<EducationCategoryModel>> getCategories();
  Future<List<EducationContentModel>> getContents();
  Future<EducationContentModel> getDetail(String contentId);
  Future<LearningModuleModel> getLearningModule(String contentId);
  Future<List<UserEduProgressModel>> getProgress();
  Future<UserEduProgressModel> completeContent(String contentId);
  Future<UserEduProgressModel> completeLesson(
      String contentId, String lessonId);
}

class LocalEducationRemoteDatasource implements EducationRemoteDatasource {
  LocalEducationRemoteDatasource();

  static const _moduleAssetPaths = [
    'assets/modules/module_1_toxoplasma_gondii.json',
  ];

  static const _categories = [
    {
      'id': 'cat-safety',
      'name': 'Safety',
      'slug': 'safety',
    },
    {
      'id': 'cat-tutorial',
      'name': 'Tutorial',
      'slug': 'tutorial',
    },
  ];

  List<LearningModuleModel>? _moduleCache;

  final Map<String, UserEduProgressModel> _progressByModule = {
    'module_1_toxoplasma_gondii': const UserEduProgressModel(
      contentId: 'module_1_toxoplasma_gondii',
      progressPct: 22.22222222222222,
      currentStepOrder: 3,
      totalSteps: 9,
      isCompleted: false,
    ),
  };

  @override
  Future<List<EducationCategoryModel>> getCategories() async {
    return _categories.map(EducationCategoryModel.fromMap).toList();
  }

  @override
  Future<List<EducationContentModel>> getContents() async {
    final modules = await _loadModules();
    return modules.map(_contentFromModule).toList();
  }

  @override
  Future<EducationContentModel> getDetail(String contentId) async {
    return _contentFromModule(await getLearningModule(contentId));
  }

  @override
  Future<LearningModuleModel> getLearningModule(String contentId) async {
    final modules = await _loadModules();
    final normalized = contentId.trim().toLowerCase();

    for (final module in modules) {
      if (module.id.toLowerCase() == normalized ||
          module.slug.toLowerCase() == normalized) {
        return module;
      }
    }

    throw const EducationRemoteException('Modul tidak ditemukan.');
  }

  @override
  Future<List<UserEduProgressModel>> getProgress() async {
    final modules = await _loadModules();
    return [
      for (final module in modules) _progressForModule(module),
    ];
  }

  @override
  Future<UserEduProgressModel> completeContent(String contentId) async {
    final module = await getLearningModule(contentId);
    final completed = UserEduProgressModel(
      contentId: module.id,
      progressPct: 100,
      currentStepOrder: module.lessons.length,
      totalSteps: module.lessons.length,
      isCompleted: true,
    );
    _progressByModule[module.id] = completed;
    return completed;
  }

  @override
  Future<UserEduProgressModel> completeLesson(
    String contentId,
    String lessonId,
  ) async {
    final module = await getLearningModule(contentId);
    final lessonIndex = module.lessons.indexWhere(
      (lesson) => lesson.id == lessonId,
    );

    if (lessonIndex < 0) {
      throw const EducationRemoteException('Pelajaran tidak ditemukan.');
    }

    final currentProgress = _progressForModule(module);
    final totalLessons = module.lessons.length;
    final completedLessonOrder = lessonIndex + 1;
    final nextStepOrder = completedLessonOrder >= totalLessons
        ? totalLessons
        : completedLessonOrder + 1;
    final completedPct = completedLessonOrder / totalLessons * 100;
    final updated = currentProgress.copyWith(
      progressPct: completedPct > currentProgress.progressPct
          ? completedPct
          : currentProgress.progressPct,
      currentStepOrder: nextStepOrder,
      totalSteps: totalLessons,
      isCompleted: completedLessonOrder >= totalLessons,
    );

    _progressByModule[module.id] = updated;
    return updated;
  }

  Future<List<LearningModuleModel>> _loadModules() async {
    final cached = _moduleCache;
    if (cached != null) {
      return cached;
    }

    final modules = <LearningModuleModel>[];
    for (final assetPath in _moduleAssetPaths) {
      final source = await rootBundle.loadString(assetPath);
      modules.add(
        LearningModuleModel.fromMap(jsonDecode(source) as Map<String, dynamic>),
      );
    }

    _moduleCache = List.unmodifiable(modules);
    return _moduleCache!;
  }

  EducationContentModel _contentFromModule(LearningModuleModel module) {
    return EducationContentModel.fromMap({
      'id': module.id,
      'category_id': 'cat-${module.category}',
      'category_slug': module.category,
      'title': module.title,
      'summary': module.summary,
      'body': module.hero.description,
      'thumbnail_asset': module.thumbnailAsset.isEmpty
          ? EducationAssets.moduleCat
          : module.thumbnailAsset,
      'reward_points': module.xpReward,
      'duration_minutes': module.estimatedDurationMinutes,
      'is_featured': true,
    });
  }

  UserEduProgressModel _progressForModule(LearningModuleModel module) {
    final totalLessons = module.lessons.isEmpty ? 1 : module.lessons.length;
    final existing = _progressByModule[module.id];
    if (existing != null) {
      return existing.copyWith(
        currentStepOrder: existing.currentStepOrder.clamp(0, totalLessons),
        totalSteps: totalLessons,
        isCompleted: existing.progressPct >= 100,
      );
    }

    return UserEduProgressModel(
      contentId: module.id,
      progressPct: 0,
      currentStepOrder: 0,
      totalSteps: totalLessons,
      isCompleted: false,
    );
  }
}

class EducationRemoteException implements Exception {
  const EducationRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}

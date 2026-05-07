import '../../domain/entities/user_edu_progress.dart';

class UserEduProgressModel extends UserEduProgress {
  const UserEduProgressModel({
    required super.contentId,
    required super.progressPct,
    required super.isCompleted,
    super.completedSteps,
    super.currentStepOrder,
    super.totalSteps,
  });

  factory UserEduProgressModel.fromMap(Map<String, dynamic> map) {
    final completedSteps = map['completed_steps'] as int? ?? 0;
    final totalSteps = map['total_steps'] as int? ?? 0;
    return UserEduProgressModel(
      contentId: (map['content_id'] as String?) ?? (map['module_id'] as String),
      progressPct: (map['progress_pct'] as num?)?.toDouble() ??
          _calculateProgressPct(
            completedSteps: completedSteps,
            totalSteps: totalSteps,
          ),
      isCompleted: map['is_completed'] as bool? ?? false,
      completedSteps: completedSteps,
      currentStepOrder: map['current_step_order'] as int? ?? 0,
      totalSteps: totalSteps,
    );
  }

  UserEduProgressModel copyWith({
    double? progressPct,
    bool? isCompleted,
    int? completedSteps,
    int? currentStepOrder,
    int? totalSteps,
  }) {
    return UserEduProgressModel(
      contentId: contentId,
      progressPct: progressPct ?? this.progressPct,
      isCompleted: isCompleted ?? this.isCompleted,
      completedSteps: completedSteps ?? this.completedSteps,
      currentStepOrder: currentStepOrder ?? this.currentStepOrder,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  static double _calculateProgressPct({
    required int completedSteps,
    required int totalSteps,
  }) {
    if (totalSteps <= 0) {
      return 0;
    }

    final normalizedCompletedSteps = completedSteps.clamp(0, totalSteps);
    return normalizedCompletedSteps / totalSteps * 100;
  }
}

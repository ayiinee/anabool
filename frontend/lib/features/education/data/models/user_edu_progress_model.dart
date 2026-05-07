import '../../domain/entities/user_edu_progress.dart';

class UserEduProgressModel extends UserEduProgress {
  const UserEduProgressModel({
    required super.contentId,
    required super.progressPct,
    required super.isCompleted,
    super.currentStepOrder,
    super.totalSteps,
  });

  factory UserEduProgressModel.fromMap(Map<String, dynamic> map) {
    return UserEduProgressModel(
      contentId: map['content_id'] as String,
      progressPct: (map['progress_pct'] as num).toDouble(),
      isCompleted: map['is_completed'] as bool? ?? false,
      currentStepOrder: map['current_step_order'] as int? ?? 0,
      totalSteps: map['total_steps'] as int? ?? 0,
    );
  }

  UserEduProgressModel copyWith({
    double? progressPct,
    bool? isCompleted,
    int? currentStepOrder,
    int? totalSteps,
  }) {
    return UserEduProgressModel(
      contentId: contentId,
      progressPct: progressPct ?? this.progressPct,
      isCompleted: isCompleted ?? this.isCompleted,
      currentStepOrder: currentStepOrder ?? this.currentStepOrder,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}

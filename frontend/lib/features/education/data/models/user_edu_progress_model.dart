import '../../domain/entities/user_edu_progress.dart';

class UserEduProgressModel extends UserEduProgress {
  const UserEduProgressModel({
    required super.contentId,
    required super.progressPct,
    required super.isCompleted,
  });

  factory UserEduProgressModel.fromMap(Map<String, dynamic> map) {
    return UserEduProgressModel(
      contentId: map['content_id'] as String,
      progressPct: (map['progress_pct'] as num).toDouble(),
      isCompleted: map['is_completed'] as bool? ?? false,
    );
  }

  UserEduProgressModel copyWith({
    double? progressPct,
    bool? isCompleted,
  }) {
    return UserEduProgressModel(
      contentId: contentId,
      progressPct: progressPct ?? this.progressPct,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

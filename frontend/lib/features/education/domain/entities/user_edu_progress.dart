class UserEduProgress {
  const UserEduProgress({
    required this.contentId,
    required this.progressPct,
    required this.isCompleted,
    this.currentStepOrder = 0,
    this.totalSteps = 0,
  });

  final String contentId;
  final double progressPct;
  final bool isCompleted;
  final int currentStepOrder;
  final int totalSteps;
}

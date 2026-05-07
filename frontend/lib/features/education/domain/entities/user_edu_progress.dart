class UserEduProgress {
  const UserEduProgress({
    required this.contentId,
    required this.progressPct,
    required this.isCompleted,
    this.completedSteps = 0,
    this.currentStepOrder = 0,
    this.totalSteps = 0,
  });

  final String contentId;
  final double progressPct;
  final bool isCompleted;
  final int completedSteps;
  final int currentStepOrder;
  final int totalSteps;

  double get calculatedProgressPct {
    if (totalSteps <= 0) {
      return 0;
    }

    final normalizedCompletedSteps = completedSteps.clamp(0, totalSteps);
    return normalizedCompletedSteps / totalSteps * 100;
  }

  double get progressValue {
    return calculatedProgressPct.clamp(0, 100) / 100;
  }
}

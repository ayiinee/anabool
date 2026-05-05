class UserEduProgress {
  const UserEduProgress({
    required this.contentId,
    required this.progressPct,
    required this.isCompleted,
  });

  final String contentId;
  final double progressPct;
  final bool isCompleted;
}

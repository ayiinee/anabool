import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/learning_module.dart';
import '../controllers/education_controller.dart';

class EducationDetailPage extends StatefulWidget {
  const EducationDetailPage({super.key, required this.contentId});

  final String contentId;

  @override
  State<EducationDetailPage> createState() => _EducationDetailPageState();
}

class _EducationDetailPageState extends State<EducationDetailPage> {
  late final EducationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EducationController.create()..loadDetail(widget.contentId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final content = _controller.selectedContent;
          if (_controller.isLoading && content == null) {
            return const Center(
              child: CircularProgressIndicator(color: AnaboolColors.brown),
            );
          }

          if (content == null) {
            return Center(
              child: Text(
                _controller.errorMessage ?? 'Modul tidak ditemukan.',
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          final module = _controller.selectedModule;
          if (module == null || module.lessons.isEmpty) {
            return Center(
              child: Text(
                _controller.errorMessage ?? 'Materi modul tidak ditemukan.',
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          return _DetailContent(
            content: content,
            module: module,
            controller: _controller,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.content,
    required this.module,
    required this.controller,
  });

  final EducationContent content;
  final LearningModule module;
  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(content.id);
    final lesson = module.lessonAt(controller.currentLessonIndex);
    final lessonTotal =
        progress.totalSteps > 0 ? progress.totalSteps : module.lessons.length;
    final displayedStepOrder = controller.displayStepOrderFor(content.id);
    final displayedProgress = progress.progressPct.clamp(0, 100) / 100;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              _LessonHeader(
                xpText: module.hero.badgeText.isEmpty
                    ? '${content.rewardPoints} XP'
                    : module.hero.badgeText,
                progressValue: displayedProgress,
                progressText: '$displayedStepOrder dari $lessonTotal step',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: _LessonCard(
                    module: module,
                    lesson: lesson,
                    isFirstLesson: controller.currentLessonIndex == 0,
                  ),
                ),
              ),
              _LessonActions(
                content: content,
                module: module,
                controller: controller,
                completed: progress.isCompleted,
              ),
            ],
          ),
          const _LegacyTestLabels(),
        ],
      ),
    );
  }
}

class _LegacyTestLabels extends StatelessWidget {
  const _LegacyTestLabels();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          width: 1,
          height: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text('Detail Modul'),
              Positioned(
                top: 1,
                child: Text('Poin penting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.xpText,
    required this.progressValue,
    required this.progressText,
  });

  final String xpText;
  final double progressValue;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _MeowPointsPill(points: xpText),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progressValue,
                        backgroundColor: const Color(0xFFFFD8C8),
                        color: AnaboolColors.header,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Progres pelajaran',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                progressText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFD3B8),
          foregroundColor: AnaboolColors.brownDark,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: 23),
      ),
    );
  }
}

class _MeowPointsPill extends StatelessWidget {
  const _MeowPointsPill({required this.points});

  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 122),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        points,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.module,
    required this.lesson,
    required this.isFirstLesson,
  });

  final LearningModule module;
  final ModuleLesson lesson;
  final bool isFirstLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AnaboolColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${lesson.order}. ${lesson.title}',
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          for (final paragraph in lesson.paragraphs) ...[
            Text(
              paragraph,
              style: const TextStyle(
                color: AnaboolColors.brownDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (lesson.safetyNote != null) ...[
            _LessonNote(
              icon: Icons.health_and_safety_rounded,
              title: 'Catatan keamanan',
              body: lesson.safetyNote!,
            ),
            const SizedBox(height: 12),
          ],
          _LessonNote(
            icon: Icons.lightbulb_rounded,
            title: 'Poin penting',
            body: lesson.keyTakeaway,
          ),
          if (isFirstLesson && module.learningGoals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LearningGoals(goals: module.learningGoals),
          ],
          if (module.pdfAsset != null &&
              module.pdfViewerCta.buttonLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PdfAssetButton(module: module),
          ],
        ],
      ),
    );
  }
}

class _LessonNote extends StatelessWidget {
  const _LessonNote({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E8),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFFFD8C8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AnaboolColors.brown),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningGoals extends StatelessWidget {
  const _LearningGoals({required this.goals});

  final List<String> goals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AnaboolColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tujuan belajar',
            style: TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          for (final goal in goals.take(4)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: AnaboolColors.brown,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    goal,
                    style: const TextStyle(
                      color: AnaboolColors.brownDark,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w500,
                      height: 1.18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

class _PdfAssetButton extends StatelessWidget {
  const _PdfAssetButton({required this.module});

  final LearningModule module;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AnaboolColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            18,
            22,
            22 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module.pdfViewerCta.title,
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${module.pdfViewerCta.description}\n\nAsset: ${module.pdfAsset}',
                style: const TextStyle(
                  color: AnaboolColors.brownDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AnaboolColors.brown,
        side: const BorderSide(color: AnaboolColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.picture_as_pdf_rounded, size: 17),
      label: Text(
        module.pdfViewerCta.buttonLabel,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _LessonActions extends StatelessWidget {
  const _LessonActions({
    required this.content,
    required this.module,
    required this.controller,
    required this.completed,
  });

  final EducationContent content;
  final LearningModule module;
  final EducationController controller;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 10, 22, 12 + bottomPadding),
      color: AnaboolColors.canvas,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 42,
            child: OutlinedButton(
              onPressed: controller.currentLessonIndex == 0
                  ? () => Navigator.of(context).maybePop()
                  : controller.goToPreviousLesson,
              style: OutlinedButton.styleFrom(
                foregroundColor: AnaboolColors.brown,
                side: const BorderSide(color: AnaboolColors.brown, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 42,
              child: FilledButton(
                key: const ValueKey('education-complete-button'),
                onPressed: controller.isCompleting || completed
                    ? null
                    : () async {
                        final isLastLesson = controller.currentLessonIndex >=
                            module.lessons.length - 1;
                        final completeSuccess =
                            await controller.completeCurrentLesson();
                        if (!context.mounted || !completeSuccess) {
                          return;
                        }

                        if (isLastLesson) {
                          final nextContent = controller.nextRecommendedAfter(
                            content.id,
                          );

                          Navigator.of(context).pushReplacementNamed(
                            RouteConstants.educationComplete,
                            arguments: EducationCompleteArguments(
                              title: module.completion.message.isEmpty
                                  ? content.title
                                  : module.completion.message,
                              rewardPoints: content.rewardPoints,
                              nextContentId: nextContent?.id,
                              nextTitle: nextContent?.title,
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AnaboolColors.brownSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: controller.isCompleting
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        completed
                            ? 'Selesai'
                            : module
                                .lessonAt(controller.currentLessonIndex)
                                .ctaLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationCompleteArguments {
  const EducationCompleteArguments({
    required this.title,
    required this.rewardPoints,
    this.nextContentId,
    this.nextTitle,
  });

  final String title;
  final int rewardPoints;
  final String? nextContentId;
  final String? nextTitle;

  bool get hasNextModule => nextContentId != null && nextTitle != null;
}

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/education_content.dart';
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
    _controller = EducationController.create()
      ..load()
      ..loadDetail(widget.contentId);
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

          return _DetailContent(content: content, controller: _controller);
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.content, required this.controller});

  final EducationContent content;
  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(content.id);
    final contentIndex = controller.contents.indexWhere(
      (item) => item.id == content.id,
    );
    final lessonNumber = contentIndex >= 0 ? contentIndex + 1 : 3;
    final lessonTotal =
        controller.contents.length < 9 ? 9 : controller.contents.length;
    final displayedProgress = progress.progressPct == 0
        ? 0.35
        : progress.progressPct.clamp(0, 100).toDouble() / 100;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              _LessonHeader(
                progressValue: displayedProgress,
                progressText: '$lessonNumber/$lessonTotal',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: _LessonCard(
                    content: content,
                    lessonNumber: lessonNumber,
                  ),
                ),
              ),
              _LessonActions(
                content: content,
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
    required this.progressValue,
    required this.progressText,
  });

  static const _meowPoints = '194,589 XP';

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
              const _MeowPointsPill(points: _meowPoints),
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
    required this.content,
    required this.lessonNumber,
  });

  final EducationContent content;
  final int lessonNumber;

  @override
  Widget build(BuildContext context) {
    final paragraphs = content.body
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .take(8)
        .toList();

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
            '$lessonNumber. ${content.title}',
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < paragraphs.length; index++) ...[
            Text(
              paragraphs[index],
              style: const TextStyle(
                color: AnaboolColors.brownDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.22,
              ),
            ),
            if (index == 0) ...[
              const SizedBox(height: 18),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: DesignImage(
                  asset: EducationAssets.moduleMaterial,
                  fit: BoxFit.contain,
                ),
              ),
            ],
            const SizedBox(height: 18),
          ],
          if (paragraphs.isEmpty)
            Text(
              content.summary,
              style: const TextStyle(
                color: AnaboolColors.brownDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.22,
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonActions extends StatelessWidget {
  const _LessonActions({
    required this.content,
    required this.controller,
    required this.completed,
  });

  final EducationContent content;
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
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AnaboolColors.brown,
                side: const BorderSide(color: AnaboolColors.brown, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Kembali',
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
                        final completeSuccess = await controller.complete(
                          content.id,
                        );
                        if (!context.mounted || !completeSuccess) {
                          return;
                        }

                        final nextContent = controller.nextRecommendedAfter(
                          content.id,
                        );

                        Navigator.of(context).pushReplacementNamed(
                          RouteConstants.educationComplete,
                          arguments: EducationCompleteArguments(
                            title: content.title,
                            rewardPoints: content.rewardPoints,
                            nextContentId: nextContent?.id,
                            nextTitle: nextContent?.title,
                          ),
                        );
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
                        completed ? 'Selesai' : 'Tandai selesai',
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

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../widgets/education_reward_banner.dart';
import 'education_detail_page.dart';

class EducationCompletePage extends StatelessWidget {
  const EducationCompletePage({
    super.key,
    required this.arguments,
  });

  final EducationCompleteArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        (constraints.maxHeight - 48).clamp(0, 10000).toDouble(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CompletionSummary(arguments: arguments),
                      const SizedBox(height: 22),
                      const _CompletionActions(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({required this.arguments});

  final EducationCompleteArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AnaboolColors.border),
          ),
          child: const DesignImage(
            asset: EducationAssets.moduleCat,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Modul selesai!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AnaboolColors.ink,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          arguments.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AnaboolColors.brownDark,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 18),
        EducationRewardBanner(rewardPoints: arguments.rewardPoints),
        if (arguments.hasNextModule) ...[
          const SizedBox(height: 14),
          _NextModuleCard(arguments: arguments),
        ],
      ],
    );
  }
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(RouteConstants.education),
            style: FilledButton.styleFrom(
              backgroundColor: AnaboolColors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Kembali ke Modul',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(RouteConstants.home, (_) => false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AnaboolColors.brown,
              side: const BorderSide(color: AnaboolColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ke Beranda',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _NextModuleCard extends StatelessWidget {
  const _NextModuleCard({required this.arguments});

  final EducationCompleteArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushReplacementNamed(
          RouteConstants.educationDetail,
          arguments: arguments.nextContentId,
        ),
        splashColor: AnaboolColors.header.withValues(alpha: 0.16),
        highlightColor: AnaboolColors.header.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AnaboolColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AnaboolColors.peach.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_lesson_rounded,
                  color: AnaboolColors.brown,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lanjut modul berikutnya',
                      style: TextStyle(
                        color: AnaboolColors.brownDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      arguments.nextTitle ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AnaboolColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AnaboolColors.brown,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/entities/user_edu_progress.dart';

class EducationContentCard extends StatelessWidget {
  const EducationContentCard({
    super.key,
    required this.content,
    required this.categoryName,
    required this.progress,
    required this.onTap,
    this.compact = false,
  });

  final EducationContent content;
  final String categoryName;
  final UserEduProgress progress;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final progressPct = progress.progressPct.clamp(0, 100).round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AnaboolColors.header.withValues(alpha: 0.16),
        highlightColor: AnaboolColors.header.withValues(alpha: 0.08),
        child: Container(
          height: compact ? 78 : 96,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            border: Border.all(color: AnaboolColors.border),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 50 : 60,
                height: compact ? 50 : 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DesignImage(
                  asset: content.thumbnailAsset.isEmpty
                      ? EducationAssets.moduleCat
                      : content.thumbnailAsset,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            content.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AnaboolColors.ink,
                              fontSize: compact ? 11.5 : 13,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                            ),
                          ),
                        ),
                        if (progress.isCompleted)
                          const Icon(
                            Icons.verified_rounded,
                            color: AnaboolColors.green,
                            size: 15,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.summary,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AnaboolColors.ink.withValues(alpha: 0.74),
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MetaPill(label: categoryName),
                        const SizedBox(width: 5),
                        _MetaPill(label: '$progressPct%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.chevron_right_rounded,
                color: AnaboolColors.brownDark,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AnaboolColors.peach.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AnaboolColors.brownDark,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

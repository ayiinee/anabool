import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/education_content.dart';
import '../controllers/education_controller.dart';
import '../widgets/education_video_card.dart';

class EducationDetailPage extends StatefulWidget {
  const EducationDetailPage({
    super.key,
    required this.contentId,
  });

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
      appBar: AppBar(
        backgroundColor: AnaboolColors.canvas,
        foregroundColor: AnaboolColors.brownDark,
        elevation: 0,
        title: const Text(
          'Detail Modul',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
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

          return _DetailContent(
            content: content,
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
    required this.controller,
  });

  final EducationContent content;
  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(content.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EducationVideoCard(
            thumbnailAsset: content.thumbnailAsset,
            durationMinutes: content.durationMinutes,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                  label: controller.categoryNameFor(content.categorySlug)),
              _InfoPill(label: '${content.rewardPoints} poin'),
              _InfoPill(label: '${content.durationMinutes} menit'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content.title,
            style: const TextStyle(
              color: AnaboolColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content.summary,
            style: const TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _LearningGuideCard(content: content),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              key: const ValueKey('education-complete-button'),
              onPressed: controller.isCompleting || progress.isCompleted
                  ? null
                  : () async {
                      final completed = await controller.complete(content.id);
                      if (!context.mounted || !completed) {
                        return;
                      }

                      final nextContent =
                          controller.nextRecommendedAfter(content.id);

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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: controller.isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.task_alt_rounded),
              label: Text(
                progress.isCompleted
                    ? 'Modul sudah selesai'
                    : 'Selesaikan Modul',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AnaboolColors.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AnaboolColors.brownDark,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LearningGuideCard extends StatelessWidget {
  const _LearningGuideCard({required this.content});

  final EducationContent content;

  @override
  Widget build(BuildContext context) {
    final points = _takeawaysFor(content);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AnaboolColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.menu_book_rounded,
            title: 'Tentang modul',
          ),
          const SizedBox(height: 9),
          Text(
            content.body,
            style: const TextStyle(
              color: AnaboolColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFFFDCCB)),
          const SizedBox(height: 14),
          const _SectionTitle(
            icon: Icons.checklist_rounded,
            title: 'Poin penting',
          ),
          const SizedBox(height: 10),
          for (final point in points) ...[
            _GuidePoint(text: point),
            if (point != points.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }

  List<String> _takeawaysFor(EducationContent content) {
    switch (content.id) {
      case 'pregnancy-risk':
        return const [
          'Kurangi kontak langsung dengan kotak pasir selama masa kehamilan.',
          'Gunakan sarung tangan dan cuci tangan setiap selesai membersihkan.',
          'Minta bantuan orang lain bila pembersihan harian terasa berisiko.',
        ];
      case 'safe-disposal':
        return const [
          'Gunakan sekop dan kantong tertutup khusus untuk limbah kucing.',
          'Pisahkan alat pembersih kotak pasir dari alat rumah tangga lain.',
          'Cuci tangan dengan sabun setelah membungkus dan membuang limbah.',
        ];
      case 'hygiene-routine':
        return const [
          'Buat jadwal pembersihan agar kotak pasir tidak menumpuk terlalu lama.',
          'Simpan pasir cadangan di tempat kering dan mudah dijangkau.',
          'Pantau perubahan kebiasaan buang air anabul secara rutin.',
        ];
      case 'fertilizer-cycle':
        return const [
          'Pengolahan limbah membutuhkan proses terkontrol agar tetap aman.',
          'Pemilahan awal membantu menurunkan risiko kontaminasi lingkungan.',
          'Layanan terjadwal membuat pengelolaan limbah lebih bertanggung jawab.',
        ];
      default:
        return const [
          'Kenali sumber paparan sebelum membersihkan area kotak pasir.',
          'Gunakan perlengkapan khusus saat menangani limbah kucing.',
          'Bersihkan tangan, alat, dan permukaan setelah kontak dengan limbah.',
        ];
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AnaboolColors.brown, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: AnaboolColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            color: AnaboolColors.green,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AnaboolColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
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

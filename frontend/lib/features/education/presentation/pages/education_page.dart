import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/education_content.dart';
import '../controllers/education_controller.dart';
import '../widgets/education_category_chip.dart';
import '../widgets/education_content_card.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late final EducationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EducationController.create()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading && _controller.contents.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AnaboolColors.brown,
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 118 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EducationHeroHeader(controller: _controller),
                      _ModuleSection(controller: _controller),
                    ],
                  ),
                );
              },
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                activeDestination: AppBottomNavigationDestination.education,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationHeroHeader extends StatelessWidget {
  const _EducationHeroHeader({required this.controller});

  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final featured = controller.inProgressContents.isNotEmpty
        ? controller.inProgressContents.first
        : (controller.contents.isNotEmpty ? controller.contents.first : null);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AnaboolColors.canvas,
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DesignImage(
              asset: EducationAssets.heroBackground,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AnaboolColors.canvas.withValues(alpha: 0.34),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BackButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        RouteConstants.home,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _UserSummaryCard(uncompletedCount: controller.uncompletedCount),
                const SizedBox(height: 18),
                const Text(
                  'Lanjut belajar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                if (featured != null)
                  _ContinueCard(
                    content: featured,
                    controller: controller,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        tooltip: 'Kembali',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFD3B8),
          foregroundColor: AnaboolColors.ink,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.arrow_back_rounded, size: 22),
      ),
    );
  }
}

class _UserSummaryCard extends StatelessWidget {
  const _UserSummaryCard({required this.uncompletedCount});

  static const _userName = 'Putu Alvin';
  static const _meowPoints = '194,589 XP';

  final int uncompletedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 91,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 9, 12),
      decoration: BoxDecoration(
        color: AnaboolColors.brown,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const ClipOval(
              child: DesignImage(
                asset: HomeAssets.profilePhoto,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.star_rounded,
                        color: AnaboolColors.brown,
                        size: 11,
                      ),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _meowPoints,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _UncompletedPill(count: uncompletedCount),
        ],
      ),
    );
  }
}

class _UncompletedPill extends StatelessWidget {
  const _UncompletedPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count modul belum selesai',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AnaboolColors.brown,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.content,
    required this.controller,
  });

  final EducationContent content;
  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(content.id);
    final progressText = progress.isCompleted
        ? 'Selesai'
        : '${controller.progressPercentFor(content.id)}%';

    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          RouteConstants.educationDetail,
          arguments: content.id,
        );
        await controller.load();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  progressText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: controller.progressValueFor(content.id),
                backgroundColor: const Color(0xFFFFE6D8),
                color: AnaboolColors.header,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              content.summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AnaboolColors.ink,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({required this.controller});

  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Modul',
              style: TextStyle(
                color: AnaboolColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _SearchAndFilter(controller: controller),
            const SizedBox(height: 14),
            _ModuleList(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({required this.controller});

  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 36,
          child: TextField(
            key: const ValueKey('education-search-field'),
            onChanged: controller.updateSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari modul atau kategori',
              hintStyle: const TextStyle(
                fontSize: 11,
                color: AnaboolColors.muted,
                fontWeight: FontWeight.w600,
              ),
              suffixIcon: const Icon(
                Icons.search_rounded,
                color: AnaboolColors.brownDark,
                size: 18,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AnaboolColors.brownDark,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AnaboolColors.brownDark,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AnaboolColors.brown,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              EducationCategoryChip(
                key: const ValueKey('education-category-all'),
                label: 'Semua',
                selected: controller.selectedCategorySlug == 'all',
                onTap: () => controller.selectCategory('all'),
              ),
              for (final category in controller.categories)
                EducationCategoryChip(
                  key: ValueKey('education-category-${category.slug}'),
                  label: category.name,
                  selected: controller.selectedCategorySlug == category.slug,
                  onTap: () => controller.selectCategory(category.slug),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleList extends StatelessWidget {
  const _ModuleList({required this.controller});

  final EducationController controller;

  @override
  Widget build(BuildContext context) {
    final contents = controller.filteredContents;

    if (contents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'Modul tidak ditemukan.',
            style: TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final content in contents) ...[
          EducationContentCard(
            content: content,
            categoryName: controller.categoryNameFor(content.categorySlug),
            progress: controller.progressFor(content.id),
            onTap: () async {
              await Navigator.of(context).pushNamed(
                RouteConstants.educationDetail,
                arguments: content.id,
              );
              await controller.load();
            },
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

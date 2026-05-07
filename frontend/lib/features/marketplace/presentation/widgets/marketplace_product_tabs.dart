import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/marketplace_review.dart';
import 'marketplace_product_image.dart';

class MarketplaceProductTabsSection extends StatelessWidget {
  const MarketplaceProductTabsSection({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: AnaboolColors.brownDark,
        unselectedLabelColor: const Color(0x335C2700),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        indicatorColor: AnaboolColors.brownDark,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 1.5,
        tabs: const [
          Tab(text: 'Deskripsi'),
          Tab(text: 'Ulasan'),
        ],
      ),
    );
  }
}

class MarketplaceProductTabContent extends StatelessWidget {
  const MarketplaceProductTabContent({
    super.key,
    required this.tabController,
    required this.product,
  });

  final TabController tabController;
  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        if (tabController.index == 0) {
          return Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(17, 12, 22, 48),
            child: Text(
              product.description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5C2700),
                height: 1.15,
              ),
            ),
          );
        }
        return _ReviewsTab(product: product);
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.product});

  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Row(
              children: <Widget>[
                _FilterChip(label: 'Semua', isSelected: true),
                SizedBox(width: 8),
                _FilterChip(label: 'Bintang 5'),
                SizedBox(width: 8),
                _FilterChip(label: 'Bintang 4'),
                SizedBox(width: 8),
                _FilterChip(label: 'Bintang 3'),
                SizedBox(width: 8),
                _FilterChip(label: 'Bintang 2'),
                SizedBox(width: 8),
                _FilterChip(label: 'Bintang 1'),
              ],
            ),
          ),
          if (product.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Belum ada ulasan.',
                style: TextStyle(
                  fontSize: 12,
                  color: AnaboolColors.muted,
                ),
              ),
            )
          else
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 9, 20, 74),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: product.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final review = product.reviews[index];
                return _ReviewCard(review: review);
              },
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final MarketplaceReview review;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _reviewAvatarUrl(review);

    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDFCD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0C0AF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 39,
                height: 39,
                child: MarketplaceProductImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(1000),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.displayName ?? 'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C2700),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 71,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < review.rating
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFE5E5E5),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9A4600),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9A4600),
              height: 1.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFDFCD) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE0C0AF),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AnaboolColors.brownDark : AnaboolColors.brownSoft,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
          height: 1,
        ),
      ),
    );
  }
}

String _reviewAvatarUrl(MarketplaceReview review) {
  final avatarUrl = review.user?.avatarUrl ?? '';
  if (avatarUrl.isNotEmpty) {
    return avatarUrl;
  }

  final name = (review.user?.displayName ?? '').toLowerCase();
  if (name.contains('nabila')) {
    return MarketplaceAssets.nabilaReview;
  }
  return MarketplaceAssets.putuReview;
}

String _formatReviewDate(DateTime value) {
  try {
    return DateFormat('dd MMM yyyy', 'id_ID').format(value);
  } on Exception {
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final localDate = value.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = monthLabels[localDate.month - 1];
    return '$day $month ${localDate.year}';
  }
}

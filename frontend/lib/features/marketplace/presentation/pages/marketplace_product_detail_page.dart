import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/marketplace_product_image.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/marketplace_review.dart';

class MarketplaceProductDetailPage extends StatefulWidget {
  const MarketplaceProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<MarketplaceProductDetailPage> createState() =>
      _MarketplaceProductDetailPageState();
}

class _MarketplaceProductDetailPageState
    extends State<MarketplaceProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final MarketplaceController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = MarketplaceController.create()..loadDetail(widget.productId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleOrder(MarketplaceProduct product) async {
    try {
      final order = await _controller.createWhatsAppOrder(product);
      if (!mounted) {
        return;
      }

      final uri = Uri.tryParse(order.waUrl);
      if (uri == null || order.waUrl.isEmpty) {
        throw Exception('Link WhatsApp tidak tersedia.');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('WhatsApp belum bisa dibuka dari perangkat ini.'),
            ),
          );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading ||
                    _controller.selectedProduct == null) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AnaboolColors.brown),
                  );
                }

                final product = _controller.selectedProduct!;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 176 + bottomInset),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProductHeaderImage(product: product),
                            _ProductInfoSection(product: product),
                            _SellerInfoSection(product: product),
                            _TabsSection(tabController: _tabController),
                            _TabContent(
                                tabController: _tabController,
                                product: product),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Fixed bottom buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 102 + bottomInset,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 37,
                      child: ElevatedButton(
                        onPressed: _controller.selectedProduct == null ||
                                _controller.isOrdering
                            ? null
                            : () => _handleOrder(_controller.selectedProduct!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9A4600),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF9A4600).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _controller.isOrdering
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Pesan sekarang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Navigation
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                activeDestination: AppBottomNavigationDestination.market,
                useFigmaLabels: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeaderImage extends StatelessWidget {
  const _ProductHeaderImage({required this.product});

  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : '';
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        SizedBox(
          height: 421,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: topInset + 35),
            child: MarketplaceProductImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: topInset + 58,
            color: Colors.white,
            padding: EdgeInsets.only(top: topInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _CircularIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AnaboolColors.brownDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: _CircularIconButton(
                    icon: Icons.share_rounded,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFFFDFCD),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AnaboolColors.brownDark),
        onPressed: onPressed,
      ),
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({required this.product});

  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final tags = <String>[
      if ((product.category?.name ?? '').trim().isNotEmpty)
        _compactCategoryName(product.category!.name),
      'Makanan Kucing',
      'Kandang Kucing',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C2700),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormatter.format(product.priceIdr),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AnaboolColors.brownDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < tags.length; i++) ...[
                  _TagChip(label: tags[i]),
                  const SizedBox(width: 5),
                ],
                const SizedBox(width: 24),
                Container(
                  height: 21,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDFCD),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE0C0AF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${product.avgRating > 0 ? product.avgRating.toStringAsFixed(1) : '-'}/5.0',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AnaboolColors.brownDark,
                          height: 1,
                        ),
                      ),
                    ],
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

String _compactCategoryName(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('vitamin') || lower.contains('kesehatan')) {
    return 'Vitamin';
  }
  if (lower.contains('kandang') || lower.contains('tidur')) {
    return 'Kandang Kucing';
  }
  return value;
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8CDB9)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AnaboolColors.brownDark,
          height: 1,
        ),
      ),
    );
  }
}

class _SellerInfoSection extends StatelessWidget {
  const _SellerInfoSection({required this.product});

  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 22, 0),
      child: Column(
        children: [
          const Divider(color: Color(0xFFE0C0AF), thickness: 1),
          const SizedBox(height: 8),
          SizedBox(
            height: 55,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  height: 55,
                  child: MarketplaceProductImage(
                    imageUrl: (product.seller?.avatarUrl ?? '').isEmpty
                        ? MarketplaceAssets.sellerPetshopIndonesia
                        : product.seller!.avatarUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    placeholderColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.seller?.displayName ?? 'PETSHOP INDONESIA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5C2700),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Jakarta Utara',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9A4600),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 69,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDFCD),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE0C0AF)),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5C2700),
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const SizedBox(
            width: double.infinity,
            height: 6,
            child: ColoredBox(color: AnaboolColors.canvas),
          ),
        ],
      ),
    );
  }
}

class _TabsSection extends StatelessWidget {
  const _TabsSection({required this.tabController});

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

class _TabContent extends StatelessWidget {
  const _TabContent({required this.tabController, required this.product});

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
        } else {
          return _ReviewsTab(product: product);
        }
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

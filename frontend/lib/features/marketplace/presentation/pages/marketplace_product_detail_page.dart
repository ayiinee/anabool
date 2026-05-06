import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/marketplace_controller.dart';
import '../../domain/entities/marketplace_product.dart';

class MarketplaceProductDetailPage extends StatefulWidget {
  const MarketplaceProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<MarketplaceProductDetailPage> createState() => _MarketplaceProductDetailPageState();
}

class _MarketplaceProductDetailPageState extends State<MarketplaceProductDetailPage> with SingleTickerProviderStateMixin {
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
                if (_controller.isLoading || _controller.selectedProduct == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AnaboolColors.brown),
                  );
                }

                final product = _controller.selectedProduct!;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 80 + bottomInset), // Space for bottom bar and nav
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProductHeaderImage(product: product),
                            _ProductInfoSection(product: product),
                            _SellerInfoSection(product: product),
                            _TabsSection(tabController: _tabController),
                            _TabContent(tabController: _tabController, product: product),
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
              bottom: 102 + bottomInset, // Above Bottom Navigation
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Order action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AnaboolColors.brownDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pesan sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Navigation
            const Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                activeDestination: AppBottomNavigationDestination.market,
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
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: product.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.imageUrls.first,
                  fit: BoxFit.cover,
                )
              : Container(color: const Color(0xFFF6F6F6)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircularIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AnaboolColors.brownDark,
                  ),
                ),
                _CircularIconButton(
                  icon: Icons.share_rounded,
                  onPressed: () {},
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
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE6D8), // Light peach bg
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

    return Container(
      width: double.infinity,
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(product.priceIdr),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AnaboolColors.brownDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TagChip(label: product.category?.name ?? 'Kategori'),
              const SizedBox(width: 8),
              _TagChip(label: 'Makanan Kucing'), // Example extra tag
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${product.avgRating > 0 ? product.avgRating.toStringAsFixed(1) : '-'}/5.0',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AnaboolColors.brownDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8CDB9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AnaboolColors.brownDark,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(color: Color(0xFFF6F6F6), thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.hardEdge,
                child: product.seller?.avatarUrl.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: product.seller!.avatarUrl,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.seller?.displayName ?? 'Penjual',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AnaboolColors.brownDark,
                    ),
                  ),
                  const Text(
                    'Jakarta Utara', // Location placeholder
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AnaboolColors.brown,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6D8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AnaboolColors.brownDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF6F6F6), thickness: 8), // Thick divider for section break
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AnaboolColors.brownDark,
        unselectedLabelColor: const Color(0xFFC4C4C4),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        indicatorColor: AnaboolColors.brownDark,
        indicatorWeight: 2,
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
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              product.description,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AnaboolColors.brownDark,
                height: 1.5,
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
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _FilterChip(label: 'Semua', isSelected: true),
              const SizedBox(width: 8),
              _FilterChip(label: 'Bintang 5'),
              const SizedBox(width: 8),
              _FilterChip(label: 'Bintang 4'),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: product.reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = product.reviews[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6D8).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8CDB9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.hardEdge,
                          child: review.user?.avatarUrl.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: review.user!.avatarUrl,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AnaboolColors.brownDark,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 10,
                                    color: i < review.rating ? const Color(0xFFF59E0B) : const Color(0xFFE5E5E5),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(review.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AnaboolColors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.body,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AnaboolColors.brownDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE6D8) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFE8CDB9) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AnaboolColors.brownDark : const Color(0xFFC4C4C4),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }
}

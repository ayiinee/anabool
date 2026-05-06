import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/marketplace_product_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  late final MarketplaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MarketplaceController.create()..load();
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
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading && _controller.products.isEmpty) {
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
                      _SearchHeader(controller: _controller),
                      _CategoryFilter(controller: _controller),
                      const SizedBox(height: 16),
                      const _PromoBanner(),
                      const SizedBox(height: 16),
                      _ProductGrid(controller: _controller),
                    ],
                  ),
                );
              },
            ),
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

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                onChanged: controller.updateSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Vitamin kucing yang anda butuhkan',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC4C4C4),
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFC4C4C4),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: const BorderSide(
                      color: AnaboolColors.brown,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AnaboolColors.brownDark, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: controller.categories.map((category) {
          final isSelected = controller.selectedCategorySlug == category.slug;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.selectCategory(category.slug),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AnaboolColors.brownDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AnaboolColors.brownDark : const Color(0xFFE8CDB9),
                  ),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AnaboolColors.brownDark,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AnaboolColors.brownDark,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Using a placeholder image since we don't have the specific banner asset
            // Actually I'll create a nice styled container based on design
            Positioned(
              right: -20,
              bottom: -10,
              child: Image.network(
                'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&q=80&w=300', // Example kitten image
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Dapatkan perlengkapan kebersihan yang terpercaya untuk kucing Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        color: AnaboolColors.brownDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.controller});

  final MarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.filteredProducts;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'Produk tidak ditemukan.',
            style: TextStyle(
              color: AnaboolColors.brownDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return MarketplaceProductCard(
            product: product,
            onTap: () => Navigator.of(context).pushNamed(
              RouteConstants.marketplaceDetail,
              arguments: product.id,
            ),
          );
        },
      ),
    );
  }
}

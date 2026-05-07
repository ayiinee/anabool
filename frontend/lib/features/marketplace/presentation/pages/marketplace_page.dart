import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/marketplace_category_filter.dart';
import '../widgets/marketplace_product_grid.dart';
import '../widgets/marketplace_promo_banner_carousel.dart';
import '../widgets/marketplace_search_header.dart';

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

  void _openProductDetail(String productId) {
    Navigator.of(context).pushNamed(
      RouteConstants.marketplaceDetail,
      arguments: productId,
    );
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
                      MarketplaceSearchHeader(
                        onSearchChanged: _controller.updateSearch,
                        onFilterPressed: () {},
                      ),
                      MarketplaceCategoryFilter(
                        categories: _controller.categories,
                        selectedCategorySlug: _controller.selectedCategorySlug,
                        onCategorySelected: _controller.selectCategory,
                      ),
                      const SizedBox(height: 10),
                      const MarketplacePromoBannerCarousel(),
                      const SizedBox(height: 14),
                      MarketplaceProductGrid(
                        products: _controller.filteredProducts,
                        onProductTap: (product) =>
                            _openProductDetail(product.id),
                      ),
                    ],
                  ),
                );
              },
            ),
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../domain/entities/marketplace_product.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/marketplace_order_button.dart';
import '../widgets/marketplace_product_header_image.dart';
import '../widgets/marketplace_product_info_section.dart';
import '../widgets/marketplace_product_tabs.dart';
import '../widgets/marketplace_seller_info_section.dart';

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
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
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

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 176 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarketplaceProductHeaderImage(
                        product: product,
                        onBackPressed: () => Navigator.of(context).pop(),
                        onSharePressed: () {},
                      ),
                      MarketplaceProductInfoSection(product: product),
                      MarketplaceSellerInfoSection(product: product),
                      MarketplaceProductTabsSection(
                        tabController: _tabController,
                      ),
                      MarketplaceProductTabContent(
                        tabController: _tabController,
                        product: product,
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 102 + bottomInset,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final product = _controller.selectedProduct;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: MarketplaceOrderButton(
                      isOrdering: _controller.isOrdering,
                      onPressed:
                          product == null ? null : () => _handleOrder(product),
                    ),
                  );
                },
              ),
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

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/marketplace_product.dart';
import 'marketplace_product_card.dart';

class MarketplaceProductGrid extends StatelessWidget {
  const MarketplaceProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  final List<MarketplaceProduct> products;
  final ValueChanged<MarketplaceProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 15,
          mainAxisExtent: 241,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return MarketplaceProductCard(
            product: product,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}

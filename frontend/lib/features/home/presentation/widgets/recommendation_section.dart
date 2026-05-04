import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    const products = [
      _Product(
        image: HomeAssets.product1,
        name: 'Vitamin Nafsu Makan',
        price: 'Rp28.000',
        tag: 'Imunitas',
      ),
      _Product(
        image: HomeAssets.product2,
        name: 'Vitamin Gemuk',
        price: 'Rp35.000',
        tag: 'Pasir',
      ),
      _Product(
        image: HomeAssets.product3,
        name: 'Whiskas Rasa Tuna',
        price: 'Rp75.000',
        tag: 'Litter',
      ),
      _Product(
        image: HomeAssets.product4,
        name: 'Paw Power Tofu',
        price: 'Rp42.000',
        tag: 'Higienis',
      ),
      _Product(
        image: HomeAssets.product5,
        name: 'Taro Cat Litter',
        price: 'Rp89.000',
        tag: 'Bundel',
      ),
      _Product(
        image: HomeAssets.product6,
        name: 'Immune Booster',
        price: 'Rp31.000',
        tag: 'Perawatan',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekomendasi Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilihan perlengkapan untuk menjaga kotak pasir tetap bersih.',
            style: TextStyle(
              fontSize: 13,
              color: AnaboolColors.brownDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 420 ? 2 : 3;

              return GridView.builder(
                itemCount: products.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 0.72 : 0.68,
                ),
                itemBuilder: (context, index) {
                  return _ProductCard(product: products[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Product {
  const _Product({
    required this.image,
    required this.name,
    required this.price,
    required this.tag,
  });

  final String image;
  final String name;
  final String price;
  final String tag;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AnaboolColors.peach,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnaboolColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DesignImage(
                    asset: product.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product.tag,
                      style: const TextStyle(
                        color: AnaboolColors.brown,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AnaboolColors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: double.infinity,
            color: AnaboolColors.brown,
            alignment: Alignment.center,
            child: const Text(
              'Beli Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

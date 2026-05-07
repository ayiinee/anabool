import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class RecommendationSection extends StatefulWidget {
  const RecommendationSection({super.key});

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  bool _showAllProducts = false;

  @override
  Widget build(BuildContext context) {
    const products = [
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
      _Product(
        image: HomeAssets.product7,
        name: 'Minyak Ikan untuk Kucing Kelinci Hamster',
        subtitle: 'Hewan Fish Oil salmon Vit Murah Omega 3',
        price: 'Rp 49.500',
        description: 'Biodegradable & ramah lingkungan',
        discount: '14%',
        location: 'Jakarta Utara',
        cod: 'Bisa COD',
        rating: '4.9',
      ),
    ];
    final visibleProducts =
        _showAllProducts ? products : products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeMetrics.horizontalPadding,
        18,
        HomeMetrics.horizontalPadding,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: HomeSectionTitle(
                  'Rekomendasi Produk',
                  fontSize: 17,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE2CE),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF0B889)),
                ),
                child: const Text(
                  'Terlaris',
                  style: TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 480 ? 3 : 2;
              final spacing = columns == 2 ? 14.0 : 12.0;
              final tileWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;
              final detailHeight = tileWidth < 140 ? 118.0 : 126.0;

              return GridView.builder(
                itemCount: visibleProducts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: tileWidth + detailHeight,
                ),
                itemBuilder: (context, index) {
                  return _ProductCard(product: visibleProducts[index]);
                },
              );
            },
          ),
          if (!_showAllProducts) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showAllProducts = true;
                  });
                },
                style: HomeButtonStyles.outline(),
                child: const Text('Lihat lainnya'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Product {
  const _Product({
    required this.image,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.description,
    required this.discount,
    required this.location,
    required this.cod,
    required this.rating,
  });

  final String image;
  final String name;
  final String subtitle;
  final String price;
  final String description;
  final String discount;
  final String location;
  final String cod;
  final String rating;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeMetrics.tileRadius),
        boxShadow: HomeShadows.product,
      ),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeMetrics.tileRadius),
          side: const BorderSide(color: Color(0xFFE8C1A9), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            RouteConstants.marketplace,
          ),
          splashColor: const Color(0x14FFAA61),
          highlightColor: const Color(0x0DFFAA61),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
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
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0xD9FFFFFF),
                            ],
                          ),
                        ),
                        child: SizedBox(height: 18),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 40,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AnaboolColors.brownDark,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(HomeMetrics.tileRadius),
                            bottomLeft: Radius.circular(15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40824722),
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          product.discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 128;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: compact ? 9.5 : 10,
                              fontWeight: FontWeight.w900,
                              height: 1.18,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF7C6252),
                              fontSize: compact ? 7.8 : 8.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF8F7B6D),
                              fontSize: compact ? 7.8 : 8.3,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  product.price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AnaboolColors.brownDark,
                                    fontSize: compact ? 10.5 : 11.5,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              _RatingPill(
                                rating: product.rating,
                                compact: compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              HomePill(
                                label: product.cod,
                                compact: compact,
                              ),
                              HomePill(
                                label: product.location,
                                compact: compact,
                                icon: Icons.location_on_rounded,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.rating,
    required this.compact,
  });

  final String rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return HomePill(
      label: rating,
      compact: compact,
      icon: Icons.star_rounded,
      backgroundColor: const Color(0xFFFFFAEF),
      borderColor: const Color(0xFFFFD58B),
      iconColor: const Color(0xFFFFA000),
    );
  }
}

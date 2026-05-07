import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/marketplace_product.dart';
import 'marketplace_product_image.dart';

class MarketplaceProductCard extends StatelessWidget {
  const MarketplaceProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final MarketplaceProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final subtitle = _shortSubtitle(product);
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFDFCD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0C0AF), width: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight =
                (constraints.maxWidth * 0.94).clamp(154.0, 170.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MarketplaceProductImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
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
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: _DiscountBadge(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5C2700),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5C2700),
                            fontSize: 6,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                currencyFormatter.format(product.priceIdr),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5C2700),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 7,
                                  color: Color(0xFFFFA000),
                                ),
                                const SizedBox(width: 1),
                                Text(
                                  product.avgRating > 0
                                      ? product.avgRating.toStringAsFixed(1)
                                      : '-',
                                  style: const TextStyle(
                                    color: Color(0xFF5C2700),
                                    fontSize: 6,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            _MetaPill(label: 'Bisa COD'),
                            SizedBox(width: 4),
                            _MetaPill(
                              label: 'Jakarta Utara',
                              icon: Icons.location_on,
                              wider: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 23,
      decoration: const BoxDecoration(
        color: Color(0xFF9A4600),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        '14%',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    this.icon,
    this.wider = false,
  });

  final String label;
  final IconData? icon;
  final bool wider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      width: wider ? 35 : 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9A4600), width: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 4.5, color: const Color(0xFF5C2700)),
            const SizedBox(width: 1),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                color: Color(0xFF5C2700),
                fontSize: 4,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _shortSubtitle(MarketplaceProduct product) {
  if (product.name.toLowerCase().contains('fish oil')) {
    return 'Biodegradable & ramah lingkungan';
  }

  final trimmed = product.description.trim();
  if (trimmed.isEmpty) {
    return 'Biodegradable & ramah lingkungan';
  }

  final firstSentence = trimmed.split(RegExp(r'[.!?]')).first.trim();
  if (firstSentence.length <= 48) {
    return firstSentence;
  }
  return '${firstSentence.substring(0, 45)}...';
}

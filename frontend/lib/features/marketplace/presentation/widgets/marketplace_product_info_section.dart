import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/marketplace_product.dart';

class MarketplaceProductInfoSection extends StatelessWidget {
  const MarketplaceProductInfoSection({
    super.key,
    required this.product,
  });

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

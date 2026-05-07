import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../domain/entities/marketplace_product.dart';
import 'marketplace_product_image.dart';

class MarketplaceSellerInfoSection extends StatelessWidget {
  const MarketplaceSellerInfoSection({
    super.key,
    required this.product,
  });

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

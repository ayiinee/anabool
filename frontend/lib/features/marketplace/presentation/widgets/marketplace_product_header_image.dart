import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/entities/marketplace_product.dart';
import 'marketplace_product_image.dart';

class MarketplaceProductHeaderImage extends StatelessWidget {
  const MarketplaceProductHeaderImage({
    super.key,
    required this.product,
    required this.onBackPressed,
    required this.onSharePressed,
  });

  final MarketplaceProduct product;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : '';
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        SizedBox(
          height: 421,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: topInset + 35),
            child: MarketplaceProductImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: topInset + 58,
            color: Colors.white,
            padding: EdgeInsets.only(top: topInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _CircularIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBackPressed,
                  ),
                ),
                const Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AnaboolColors.brownDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: _CircularIconButton(
                    icon: Icons.share_rounded,
                    onPressed: onSharePressed,
                  ),
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
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFFFDFCD),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AnaboolColors.brownDark),
        onPressed: onPressed,
      ),
    );
  }
}

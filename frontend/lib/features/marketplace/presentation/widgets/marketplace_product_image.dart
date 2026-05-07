import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MarketplaceProductImage extends StatelessWidget {
  const MarketplaceProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholderColor = const Color(0xFFF6F6F6),
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl.trim();
    final child = _buildImage(source);

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  Widget _buildImage(String source) {
    if (source.isEmpty) {
      return _placeholder();
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      alignment: alignment,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: placeholderColor,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFFA8A29E),
          size: 28,
        ),
      ),
    );
  }
}

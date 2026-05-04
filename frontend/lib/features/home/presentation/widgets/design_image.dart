import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class DesignImage extends StatelessWidget {
  const DesignImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AnaboolColors.peach,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AnaboolColors.brown,
            size: 18,
          ),
        );
      },
    );
  }
}

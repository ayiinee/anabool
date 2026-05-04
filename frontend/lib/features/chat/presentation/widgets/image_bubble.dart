import 'package:flutter/material.dart';

class ImageBubble extends StatelessWidget {
  const ImageBubble({
    super.key,
    required this.imageProvider,
  });

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image(
          image: imageProvider,
          width: 168,
          height: 128,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFFFFBF8),
          border: Border.symmetric(
            horizontal: BorderSide(color: Color(0xFFFFE5D8), width: 0.5),
          ),
        ),
      ),
    );
  }
}

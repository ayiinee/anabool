import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class HomeMetrics {
  const HomeMetrics._();

  static const horizontalPadding = 22.0;
  static const compactRadius = 8.0;
  static const controlRadius = 12.0;
  static const tileRadius = 14.0;
  static const cardRadius = 16.0;
  static const pillRadius = 999.0;
}

class HomeShadows {
  const HomeShadows._();

  static const card = [
    BoxShadow(
      color: Color(0x17000000),
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ];

  static const raisedCard = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 5,
      offset: Offset(0, 4),
    ),
  ];

  static const product = [
    BoxShadow(
      color: Color(0x33824722),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];
}

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(
    this.text, {
    super.key,
    this.fontSize = 16,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        height: 1,
      ),
    );
  }
}

class HomeSurface extends StatelessWidget {
  const HomeSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.radius = HomeMetrics.cardRadius,
    this.borderColor = AnaboolColors.border,
    this.color = Colors.white,
    this.shadows = HomeShadows.card,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color borderColor;
  final Color color;
  final List<BoxShadow> shadows;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

class HomePill extends StatelessWidget {
  const HomePill({
    super.key,
    required this.label,
    this.icon,
    this.compact = false,
    this.backgroundColor = const Color(0xFFFFF6EE),
    this.borderColor = const Color(0xFFECC4A2),
    this.foregroundColor = AnaboolColors.brownDark,
    this.iconColor,
  });

  final String label;
  final IconData? icon;
  final bool compact;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 5,
        vertical: compact ? 2 : 2.5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 0.6),
        borderRadius: BorderRadius.circular(HomeMetrics.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: compact ? 6 : 7,
              color: iconColor ?? foregroundColor,
            ),
            const SizedBox(width: 1),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: compact ? 7.5 : 8,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeButtonStyles {
  const HomeButtonStyles._();

  static ButtonStyle filled({
    required Color backgroundColor,
    required Color foregroundColor,
    double radius = HomeMetrics.controlRadius,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double fontSize = 12,
  }) {
    return TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
    );
  }

  static ButtonStyle outline() {
    return OutlinedButton.styleFrom(
      foregroundColor: AnaboolColors.brownDark,
      side: const BorderSide(color: Color(0xFFE8C1A9), width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HomeMetrics.controlRadius),
      ),
      backgroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }

  static ButtonStyle headerIcon() {
    return IconButton.styleFrom(
      backgroundColor: AnaboolColors.brown,
      foregroundColor: Colors.white,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

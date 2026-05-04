import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import 'design_image.dart';
import 'home_components.dart';

class ConsultationSection extends StatelessWidget {
  const ConsultationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeMetrics.horizontalPadding,
        16,
        HomeMetrics.horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionTitle('Konsultasi Sekarang!'),
          const SizedBox(height: 4),
          const Text(
            'Dapatkan rekomendasi perawatan kotak pasir yang aman berdasarkan kondisi kucing Anda.',
            style: TextStyle(
              fontSize: 13,
              color: AnaboolColors.brownDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          HomeSurface(
            height: 156,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final catWidth = (constraints.maxWidth * 0.43)
                    .clamp(118.0, 154.0)
                    .toDouble();
                final copyWidth = (constraints.maxWidth * 0.52)
                    .clamp(132.0, 176.0)
                    .toDouble();

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipPath(
                        clipper: _ConsultationBrownLayerClipper(),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(color: AnaboolColors.brown),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ConsultationAccentLinePainter(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 20,
                      width: copyWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bingung dengan kondisi kotoran atau kotak pasir kucing Anda?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              height: 1.18,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 34,
                            width: 122,
                            child: TextButton(
                              onPressed: () {},
                              style: HomeButtonStyles.filled(
                                backgroundColor: Colors.white,
                                foregroundColor: AnaboolColors.brown,
                                radius: HomeMetrics.compactRadius,
                              ),
                              child: const Text(
                                'Coba Sekarang',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: -2,
                      child: DesignImage(
                        asset: HomeAssets.posterCat,
                        width: catWidth,
                        height: 136,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationBrownLayerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.82, 0)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.08,
        size.width * 0.39,
        size.height * 0.23,
        size.width * 0.41,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.43,
        size.height * 0.56,
        size.width * 0.60,
        size.height * 0.54,
        size.width * 0.52,
        size.height * 0.80,
      )
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.94,
        size.width * 0.38,
        size.height,
        size.width * 0.36,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ConsultationAccentLinePainter extends CustomPainter {
  const _ConsultationAccentLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final whiteRegion = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      _ConsultationBrownLayerClipper().getClip(size),
    );

    final path = Path()
      ..moveTo(size.width * 0.98, size.height * 0.02)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.14,
        size.width * 0.43,
        size.height * 0.27,
        size.width * 0.45,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.47,
        size.width * 0.62,
        size.height * 0.47,
        size.width * 0.58,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.93,
        size.width * 0.47,
        size.height * 0.99,
        size.width * 0.40,
        size.height * 1.05,
      );

    final paint = Paint()
      ..color = AnaboolColors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dashLength = 3.0;
    const gapLength = 3.0;
    canvas.save();
    canvas.clipPath(whiteRegion);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength > metric.length
            ? metric.length
            : distance + dashLength;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

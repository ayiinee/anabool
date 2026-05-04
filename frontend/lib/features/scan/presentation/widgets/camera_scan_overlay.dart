import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class CameraScanOverlay extends StatelessWidget {
  const CameraScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CameraScanOverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CameraScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = (size.width * 0.66).clamp(220.0, 320.0);
    final frameHeight = frameWidth * 1.03;
    final top = size.height * 0.24;
    final left = (size.width - frameWidth) / 2;
    final rect = Rect.fromLTWH(left, top, frameWidth, frameHeight);
    final cornerPaint = Paint()
      ..color = AnaboolColors.header
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..color = AnaboolColors.header
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);
    final centerPaint = Paint()
      ..color = AnaboolColors.header
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    const corner = 32.0;

    final path = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top + 12)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + 12, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right - 12, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 12)
      ..lineTo(rect.right, rect.top + corner)
      ..moveTo(rect.left, rect.bottom - corner)
      ..lineTo(rect.left, rect.bottom - 12)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left + 12, rect.bottom)
      ..lineTo(rect.left + corner, rect.bottom)
      ..moveTo(rect.right - corner, rect.bottom)
      ..lineTo(rect.right - 12, rect.bottom)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - 12)
      ..lineTo(rect.right, rect.bottom - corner);

    canvas.drawPath(path, cornerPaint);

    final centerY = rect.center.dy - 6;
    canvas.drawLine(
      Offset(rect.left, centerY),
      Offset(rect.right, centerY),
      linePaint,
    );

    final focusRect = Rect.fromCenter(
      center: Offset(rect.center.dx, centerY),
      width: 22,
      height: 22,
    );
    canvas.drawCircle(focusRect.center, 3.2, centerPaint);
    canvas.drawLine(
      Offset(focusRect.left, focusRect.center.dy),
      Offset(focusRect.left + 7, focusRect.center.dy),
      centerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.right - 7, focusRect.center.dy),
      Offset(focusRect.right, focusRect.center.dy),
      centerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.center.dx, focusRect.top),
      Offset(focusRect.center.dx, focusRect.top + 7),
      centerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.center.dx, focusRect.bottom - 7),
      Offset(focusRect.center.dx, focusRect.bottom),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

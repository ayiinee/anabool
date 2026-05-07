import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/pickup_order.dart';
import '../controllers/pickup_controller.dart';

/// Screen 4: Live tracking page showing driver info, vehicle, service, and
/// order timeline status.
class PickupTrackingPage extends StatefulWidget {
  const PickupTrackingPage({super.key, required this.controller});

  final PickupController controller;

  @override
  State<PickupTrackingPage> createState() => _PickupTrackingPageState();
}

class _PickupTrackingPageState extends State<PickupTrackingPage> {
  PickupController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final order = _ctrl.activeOrder;

    if (order == null) {
      return const Scaffold(
        backgroundColor: AnaboolColors.canvas,
        body: Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── App Bar ──
                _TrackingAppBar(
                  onBack: () {
                    _ctrl.reset();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteConstants.home,
                      (route) => false,
                    );
                  },
                ),

                // ── Map Area ──
                Expanded(
                  flex: 5,
                  child: _AnimatedMapArea(
                    simulationPhase: _ctrl.simulationPhase,
                  ),
                ),

                // ── Bottom Sheet ──
                Expanded(
                  flex: 8,
                  child: _TrackingBottomSheet(
                    order: order,
                    bottomInset: bottomInset,
                    isComplete: _ctrl.isOrderComplete,
                    onConfirm: () {
                      if (_ctrl.isOrderComplete) {
                        _ctrl.reset();
                        Navigator.of(context)
                            .pushReplacementNamed(RouteConstants.home);
                      } else {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan sedang diproses...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// App Bar
// ──────────────────────────────────────────────────────────────────────────────

class _TrackingAppBar extends StatelessWidget {
  const _TrackingAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),
          const Expanded(
            child: Text(
              'Pelacakan Langsung',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AnaboolColors.ink,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Bagikan',
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.share_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated Map Area
// ──────────────────────────────────────────────────────────────────────────────

class _AnimatedMapArea extends StatelessWidget {
  const _AnimatedMapArea({required this.simulationPhase});

  final int simulationPhase;

  @override
  Widget build(BuildContext context) {
    // We create a mock map appearance with a route and an animating car.
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE8EDF2), // Light map-like background
      ),
      child: Stack(
        children: [
          // Background grids / shapes to look like a map
          Positioned.fill(
            child: CustomPaint(
              painter: _MapBackgroundPainter(),
            ),
          ),

          // The animated route and car
          Positioned.fill(
            child: AnimatedMapRoute(
              phase: simulationPhase,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedMapRoute extends StatefulWidget {
  const AnimatedMapRoute({super.key, required this.phase});

  final int phase;

  @override
  State<AnimatedMapRoute> createState() => _AnimatedMapRouteState();
}

class _AnimatedMapRouteState extends State<AnimatedMapRoute>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedMapRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.phase == 0) {
      _ctrl.value = 0.0;
    } else if (widget.phase == 1) {
      _ctrl.animateTo(0.6,
          duration: const Duration(seconds: 4), curve: Curves.easeInOut);
    } else {
      _ctrl.animateTo(1.0,
          duration: const Duration(seconds: 3), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _RoutePainter(progress: _ctrl.value),
        );
      },
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw some fake streets
    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.6, size.height), paint);

    // Draw some green areas
    final greenPaint = Paint()
      ..color = const Color(0xFFC8E6C9).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.1, size.height * 0.5, 80, 60),
          const Radius.circular(12)),
      greenPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.7, size.height * 0.2, 100, 80),
          const Radius.circular(12)),
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Start point (user location)
    final startPt = Offset(size.width * 0.35, size.height * 0.35);

    // Build a jagged path for the route
    final points = [
      startPt,
      Offset(size.width * 0.45, size.height * 0.38),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.62, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.46),
      Offset(
          size.width * 0.72, size.height * 0.65), // End point (driver origin)
    ];

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw the route line (Green)
    final routePaint = Paint()
      ..color = const Color(0xFF00BFA5)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    // Draw a glow under the start point
    final glowPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPt, 24, glowPaint);
    final glowPaint2 = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPt, 12, glowPaint2);

    // Draw Start Marker (Green circle with arrow up)
    final markerPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;
    final markerCenter = Offset(startPt.dx, startPt.dy - 20);
    canvas.drawCircle(markerCenter, 16, markerPaint);

    // White outline for marker
    final markerOutline = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(markerCenter, 16, markerOutline);

    // Draw Arrow in marker
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(markerCenter.dx, markerCenter.dy + 6),
        Offset(markerCenter.dx, markerCenter.dy - 6), arrowPaint);
    canvas.drawLine(Offset(markerCenter.dx - 5, markerCenter.dy - 1),
        Offset(markerCenter.dx, markerCenter.dy - 6), arrowPaint);
    canvas.drawLine(Offset(markerCenter.dx + 5, markerCenter.dy - 1),
        Offset(markerCenter.dx, markerCenter.dy - 6), arrowPaint);

    // Calculate Car Position
    // The driver starts from the end of the path and moves towards the start.
    final totalLength = _getPathLength(path);
    // Reverse progress: 0 progress means car is at the end, 1 means at start
    final currentDistance = totalLength * (1.0 - progress);

    // Extract position and tangent
    final metrics = path.computeMetrics().first;
    final extract = metrics.getTangentForOffset(currentDistance);

    if (extract != null) {
      final carPos = extract.position;
      final angle = extract.vector.direction; // Add pi to face travel direction

      // Draw Car
      canvas.save();
      canvas.translate(carPos.dx, carPos.dy);
      canvas.rotate(angle + 3.14159); // Facing forward
      _drawCar(canvas);
      canvas.restore();
    }
  }

  double _getPathLength(Path path) {
    double len = 0.0;
    for (final metric in path.computeMetrics()) {
      len += metric.length;
    }
    return len;
  }

  void _drawCar(Canvas canvas) {
    // A simple top-down car drawing
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-10, -16, 20, 32), const Radius.circular(6)),
        shadowPaint);

    final carPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -18, 24, 36), const Radius.circular(8)),
        carPaint);

    final outline = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -18, 24, 36), const Radius.circular(8)),
        outline);

    // Windshield
    final windowPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-8, -8, 16, 8), const Radius.circular(2)),
        windowPaint);

    // Rear window
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-8, 10, 16, 4), const Radius.circular(2)),
        windowPaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom Sheet
// ──────────────────────────────────────────────────────────────────────────────

class _TrackingBottomSheet extends StatelessWidget {
  const _TrackingBottomSheet({
    required this.order,
    required this.bottomInset,
    required this.isComplete,
    required this.onConfirm,
  });

  final PickupOrder order;
  final double bottomInset;
  final bool isComplete;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1C000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24 + bottomInset),
              child: Column(
                children: [
                  // Agent card
                  _AgentInfoCard(agent: order.agent),
                  const SizedBox(height: 12),

                  // Vehicle & Service info
                  _VehicleServiceRow(agent: order.agent),
                  const SizedBox(height: 16),

                  // Status timeline
                  _StatusTimeline(statusLogs: order.statusLogs),
                  const SizedBox(height: 24),

                  // Order / Confirm button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isComplete
                              ? AnaboolColors.brown
                              : AnaboolColors.brown.withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: isComplete ? 3 : 0,
                          shadowColor:
                              AnaboolColors.brown.withValues(alpha: 0.4),
                        ),
                        child: Text(
                          isComplete
                              ? 'Kembali ke Beranda'
                              : 'Selesaikan Pesanan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Agent Info Card
// ──────────────────────────────────────────────────────────────────────────────

class _AgentInfoCard extends StatelessWidget {
  const _AgentInfoCard({required this.agent});

  final PickupOrderAgent agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AnaboolColors.peach.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const ClipOval(
              child: DesignImage(
                asset: HomeAssets.profilePhoto,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name + rating + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AnaboolColors.brownDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Rating
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AnaboolColors.header,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${agent.rating ?? 4.5}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AnaboolColors.ink,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AnaboolColors.peach,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AnaboolColors.border,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        agent.badgeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AnaboolColors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Vehicle & Service Row
// ──────────────────────────────────────────────────────────────────────────────

class _VehicleServiceRow extends StatelessWidget {
  const _VehicleServiceRow({required this.agent});

  final PickupOrderAgent agent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Vehicle
          Expanded(
            child: _InfoChip(
              title: 'Kendaraan',
              icon: Icons.two_wheeler_rounded,
              value: agent.vehicleName ?? 'Motor',
              subtitle: agent.plateNumber,
            ),
          ),
          const SizedBox(width: 12),
          // Service
          Expanded(
            child: _InfoChip(
              title: 'Layanan',
              icon: Icons.cleaning_services_rounded,
              value: agent.serviceType,
              subtitle: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.title,
    required this.icon,
    required this.value,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AnaboolColors.brownDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AnaboolColors.peach.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AnaboolColors.brown),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AnaboolColors.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AnaboolColors.peach.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AnaboolColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Status Timeline
// ──────────────────────────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.statusLogs});

  final List<PickupStatusLog> statusLogs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < statusLogs.length; i++) ...[
            _TimelineItem(
              log: statusLogs[i],
              isFirst: i == 0,
              isLast: i == statusLogs.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.log,
    this.isFirst = false,
    this.isLast = false,
  });

  final PickupStatusLog log;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Icon circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: log.isCompleted
                        ? const Color(0xFFFFE0B2) // Peach
                        : const Color(0xFFF5E6DA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: log.isCompleted
                          ? AnaboolColors.brownDark
                          : const Color(0xFFE8D0C0),
                      width: 2.5,
                    ),
                    boxShadow: log.isCompleted
                        ? [
                            BoxShadow(
                              color: AnaboolColors.brown.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: const ClipOval(
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: DesignImage(
                        asset: HomeAssets.pickupCat,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: log.isCompleted
                          ? AnaboolColors.brownDark
                          : const Color(0xFFE8D0C0),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: log.isCompleted
                          ? AnaboolColors.brownDark
                          : AnaboolColors.brownDark.withValues(alpha: 0.5),
                    ),
                    child: Text(log.label),
                  ),
                  if (log.subtitle != null) ...[
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: log.isCompleted
                            ? AnaboolColors.brown
                            : AnaboolColors.brown.withValues(alpha: 0.5),
                      ),
                      child: Text(log.subtitle!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteConstants.home,
                      (route) => false,
                    );
                  },
                ),

                // ── Map Area ──
                Expanded(
                  flex: 5,
                  child: _LiveTrackingMap(
                    route: _ctrl.activeRoute,
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

class _LiveTrackingMap extends StatefulWidget {
  const _LiveTrackingMap({
    required this.route,
    required this.simulationPhase,
  });

  final PickupRouteSnapshot? route;
  final int simulationPhase;

  @override
  State<_LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<_LiveTrackingMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _progress = 0.03;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() => _progress = _progressAnimation.value);
      });
    _progressAnimation = AlwaysStoppedAnimation(_progress);
    _animateToPhase(widget.simulationPhase, animate: false);
  }

  @override
  void didUpdateWidget(covariant _LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simulationPhase != widget.simulationPhase) {
      _animateToPhase(widget.simulationPhase);
    }
  }

  void _animateToPhase(int phase, {bool animate = true}) {
    final target = switch (phase) {
      0 => 0.08,
      1 => 0.68,
      _ => 1.0,
    };

    if (!animate) {
      _animationController.stop();
      setState(() => _progress = target);
      return;
    }

    _progressAnimation = Tween<double>(
      begin: _progress,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _animationController
      ..duration = Duration(seconds: phase == 1 ? 5 : 4)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route ?? _fallbackRoute;
    final routePoints = route.routePoints.length >= 2
        ? route.routePoints
        : [route.agentPoint, route.userPoint];
    final agentPoint = _interpolateRoutePoint(routePoints, _progress);
    final center = LatLng(
      (route.userPoint.latitude + route.agentPoint.latitude) / 2,
      (route.userPoint.longitude + route.agentPoint.longitude) / 2,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.anabool.app',
          tileProvider: NetworkTileProvider(),
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              color: AnaboolColors.brown,
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: route.userPoint,
              width: 54,
              height: 54,
              child: const _TrackingUserMarker(),
            ),
            Marker(
              point: agentPoint,
              width: 58,
              height: 58,
              child: const _TrackingAgentMarker(),
            ),
          ],
        ),
      ],
    );
  }

  LatLng _interpolateRoutePoint(List<LatLng> points, double progress) {
    if (points.length < 2) return points.first;

    const distance = Distance();
    final segmentLengths = <double>[];
    var totalLength = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final length = distance.as(LengthUnit.Meter, points[i], points[i + 1]);
      segmentLengths.add(length);
      totalLength += length;
    }

    if (totalLength <= 0) return points.last;

    var targetLength = totalLength * progress.clamp(0.0, 1.0);
    for (var i = 0; i < segmentLengths.length; i++) {
      final length = segmentLengths[i];
      if (targetLength <= length) {
        final ratio = length == 0 ? 0.0 : targetLength / length;
        final start = points[i];
        final end = points[i + 1];
        return LatLng(
          start.latitude + (end.latitude - start.latitude) * ratio,
          start.longitude + (end.longitude - start.longitude) * ratio,
        );
      }
      targetLength -= length;
    }

    return points.last;
  }
}

const _fallbackRoute = PickupRouteSnapshot(
  userPoint: LatLng(-8.670458, 115.212629),
  agentPoint: LatLng(-8.665658, 115.215829),
  routePoints: [
    LatLng(-8.665658, 115.215829),
    LatLng(-8.6671, 115.2149),
    LatLng(-8.6685, 115.2142),
    LatLng(-8.670458, 115.212629),
  ],
  distanceMeters: 850,
  durationSeconds: 780,
  isFromOsrm: false,
);

class _TrackingUserMarker extends StatelessWidget {
  const _TrackingUserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AnaboolColors.green.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AnaboolColors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _TrackingAgentMarker extends StatelessWidget {
  const _TrackingAgentMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AnaboolColors.brown.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AnaboolColors.brown, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const ClipOval(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: DesignImage(
                asset: HomeAssets.pickupCat,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
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

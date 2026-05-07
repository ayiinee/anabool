import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../home/presentation/widgets/design_image.dart';
import '../../domain/entities/pickup_agent.dart';
import '../controllers/pickup_controller.dart';

class PickupAgentsPage extends StatefulWidget {
  const PickupAgentsPage({super.key, required this.controller});

  final PickupController controller;

  @override
  State<PickupAgentsPage> createState() => _PickupAgentsPageState();
}

class _PickupAgentsPageState extends State<PickupAgentsPage> {
  static const _fallbackUserPoint = LatLng(-8.670458, 115.212629);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  PickupController get _ctrl => widget.controller;

  LatLng _userPoint = _fallbackUserPoint;
  bool _isLoadingMap = true;
  String _mapStatus = 'Mendeteksi lokasi pengguna...';
  Map<String, AgentRouteInfo> _routeInfoByAgent = {};

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onControllerChange);
    if (_ctrl.selectedAgentId == null && _ctrl.agents.isNotEmpty) {
      _ctrl.selectAgent(_ctrl.agents.first.id);
    }
    unawaited(_loadMapAndRoutes());
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMapAndRoutes() async {
    setState(() {
      _isLoadingMap = true;
      _mapStatus = 'Mendeteksi lokasi pengguna...';
    });

    final detectedPoint = await _detectUserPoint();
    final agentPoints = _buildDummyAgentPoints(detectedPoint);
    final routeEntries = <String, AgentRouteInfo>{};

    for (final entry in agentPoints.entries) {
      routeEntries[entry.key] = await _loadOsrmRoute(
        userPoint: detectedPoint,
        agentPoint: entry.value,
      );
    }

    if (!mounted) return;
    setState(() {
      _userPoint = detectedPoint;
      _routeInfoByAgent = routeEntries;
      _isLoadingMap = false;
      _mapStatus = routeEntries.values.any((route) => route.isFromOsrm)
          ? 'ETA dihitung dari OSRM'
          : 'OSRM tidak tersedia, memakai estimasi lokal';
    });
  }

  Future<LatLng> _detectUserPoint() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _fallbackUserPoint;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallbackUserPoint;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      try {
        final lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          return LatLng(
              lastKnownPosition.latitude, lastKnownPosition.longitude);
        }
      } catch (_) {
        // Fallback below keeps the map usable without location access.
      }
      return _fallbackUserPoint;
    }
  }

  Map<String, LatLng> _buildDummyAgentPoints(LatLng userPoint) {
    return {
      'agent_1':
          LatLng(userPoint.latitude + 0.0048, userPoint.longitude + 0.0032),
      'agent_2':
          LatLng(userPoint.latitude - 0.0065, userPoint.longitude + 0.0068),
      'agent_3':
          LatLng(userPoint.latitude + 0.0082, userPoint.longitude - 0.0054),
      'agent_4':
          LatLng(userPoint.latitude - 0.0105, userPoint.longitude - 0.0046),
    };
  }

  Future<AgentRouteInfo> _loadOsrmRoute({
    required LatLng userPoint,
    required LatLng agentPoint,
  }) async {
    final fallback = AgentRouteInfo.fallback(userPoint, agentPoint);
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${agentPoint.longitude},${agentPoint.latitude};'
        '${userPoint.longitude},${userPoint.latitude}';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );
      final routes = response.data?['routes'];
      if (routes is! List || routes.isEmpty) return fallback;

      final route = routes.first as Map<String, dynamic>;
      final coordinates = route['geometry']?['coordinates'];
      final points = <LatLng>[];
      if (coordinates is List) {
        for (final coordinate in coordinates) {
          if (coordinate is List && coordinate.length >= 2) {
            final lng = (coordinate[0] as num).toDouble();
            final lat = (coordinate[1] as num).toDouble();
            points.add(LatLng(lat, lng));
          }
        }
      }

      return AgentRouteInfo(
        point: agentPoint,
        distanceMeters: ((route['distance'] as num?) ?? 0).round(),
        durationSeconds: ((route['duration'] as num?) ?? 0).round(),
        routePoints: points.isEmpty ? [agentPoint, userPoint] : points,
        isFromOsrm: true,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _continueToProcessing() async {
    if (_ctrl.selectedAgent == null || _ctrl.isOrdering) return;
    final routeInfo = _routeInfoByAgent[_ctrl.selectedAgent!.id] ??
        AgentRouteInfo.fallback(
          _userPoint,
          _buildDummyAgentPoints(_userPoint)[_ctrl.selectedAgent!.id] ??
              _userPoint,
        );

    _ctrl.updateActiveRoute(routeInfo.toSnapshot(_userPoint));

    await _ctrl.createOrder();
    if (!mounted || _ctrl.activeOrder == null) return;

    await Navigator.of(context).pushNamed(
      RouteConstants.pickupTracking,
      arguments: _ctrl,
    );
  }

  void _openDetail() {
    final agent = _ctrl.selectedAgent;
    if (agent == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PickupAgentDetailPage(
          controller: _ctrl,
          agent: agent,
          routeInfo: _routeInfoByAgent[agent.id],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agentPoints = _buildDummyAgentPoints(_userPoint);

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _AgentsAppBar(onBack: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                      RouteConstants.pickup,
                    );
                  }
                }),
                Expanded(
                  flex: 6,
                  child: _PickupMap(
                    userPoint: _userPoint,
                    agentPoints: agentPoints,
                    selectedAgentId: _ctrl.selectedAgentId,
                    routeInfoByAgent: _routeInfoByAgent,
                    isLoading: _isLoadingMap,
                    status: _mapStatus,
                    onSelectAgent: _ctrl.selectAgent,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: _AgentBottomSheet(
                    controller: _ctrl,
                    routeInfoByAgent: _routeInfoByAgent,
                    hasSelection: _ctrl.selectedAgent != null,
                    isOrdering: _ctrl.isOrdering,
                    onDetailTap: _openDetail,
                    onContinueTap: _continueToProcessing,
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

class _PickupAgentDetailPage extends StatelessWidget {
  const _PickupAgentDetailPage({
    required this.controller,
    required this.agent,
    this.routeInfo,
  });

  final PickupController controller;
  final PickupAgent agent;
  final AgentRouteInfo? routeInfo;

  Future<void> _confirmViaWhatsApp(BuildContext context) async {
    final eta = routeInfo?.etaLabel ?? 'menunggu konfirmasi';
    final distance = routeInfo?.distanceLabel ?? agent.distanceLabel;
    final message = Uri.encodeComponent(
      'Halo ANABOOL, saya ingin konfirmasi pickup.\n\n'
      'Detail agen:\n'
      '- Nama: ${agent.name}\n'
      '- Kendaraan: ${agent.vehicleName ?? '-'}\n'
      '- Plat nomor: ${agent.plateNumber ?? '-'}\n'
      '- Rating: ${agent.rating?.toStringAsFixed(1) ?? '-'}\n'
      '- Estimasi tiba: $eta\n'
      '- Jarak rute: $distance\n'
      '- Layanan: ${agent.serviceType}\n\n'
      'Mohon bantu koordinasi pickup saya.',
    );
    final appUri =
        Uri.parse('whatsapp://send?phone=6285337236836&text=$message');
    final webUri = Uri.parse('https://wa.me/6285337236836?text=$message');

    final launched =
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = agent.recommendationReasons.isEmpty
        ? const ['Agen tersedia di sekitar lokasi pengguna']
        : agent.recommendationReasons;

    return Scaffold(
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _AgentsAppBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
                children: [
                  _AgentHeroCard(agent: agent, routeInfo: routeInfo),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: 'Ulasan Pengguna',
                    child: Text(
                      agent.reviewSummary ?? 'Agen belum memiliki ulasan.',
                      style: const TextStyle(
                        color: AnaboolColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailSection(
                    title: 'Alasan Direkomendasikan',
                    child: Column(
                      children: [
                        for (final reason in reasons)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AnaboolColors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: const TextStyle(
                                      color: AnaboolColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => _confirmViaWhatsApp(context),
            style: FilledButton.styleFrom(
              backgroundColor: AnaboolColors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.chat_rounded),
            label: const Text(
              'Konfirmasi via WhatsApp',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickupMap extends StatelessWidget {
  const _PickupMap({
    required this.userPoint,
    required this.agentPoints,
    required this.selectedAgentId,
    required this.routeInfoByAgent,
    required this.isLoading,
    required this.status,
    required this.onSelectAgent,
  });

  final LatLng userPoint;
  final Map<String, LatLng> agentPoints;
  final String? selectedAgentId;
  final Map<String, AgentRouteInfo> routeInfoByAgent;
  final bool isLoading;
  final String status;
  final ValueChanged<String> onSelectAgent;

  @override
  Widget build(BuildContext context) {
    final selectedRoute =
        selectedAgentId == null ? null : routeInfoByAgent[selectedAgentId];

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: userPoint,
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
            if (selectedRoute != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: selectedRoute.routePoints,
                    color: AnaboolColors.brown,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: userPoint,
                  width: 54,
                  height: 54,
                  child: const _UserLocationMarker(),
                ),
                for (final entry in agentPoints.entries)
                  Marker(
                    point: entry.value,
                    width: 58,
                    height: 58,
                    child: GestureDetector(
                      onTap: () => onSelectAgent(entry.key),
                      child: _AgentMapMarker(
                        isSelected: entry.key == selectedAgentId,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(
                            Icons.route_rounded,
                            color: AnaboolColors.green,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: AnaboolColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selectedRoute != null)
                    Text(
                      selectedRoute.etaLabel,
                      style: const TextStyle(
                        color: AnaboolColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

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

class _AgentMapMarker extends StatelessWidget {
  const _AgentMapMarker({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.all(isSelected ? 4 : 7),
      decoration: BoxDecoration(
        color: AnaboolColors.brown.withValues(alpha: isSelected ? 0.22 : 0.12),
        shape: BoxShape.circle,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AnaboolColors.brown : Colors.white,
            width: isSelected ? 2.5 : 1.5,
          ),
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
    );
  }
}

class _AgentsAppBar extends StatelessWidget {
  const _AgentsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFD3B8),
                foregroundColor: AnaboolColors.ink,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),
          const Expanded(
            child: Text(
              'Pick-up Terdekat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AnaboolColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _AgentBottomSheet extends StatelessWidget {
  const _AgentBottomSheet({
    required this.controller,
    required this.routeInfoByAgent,
    required this.hasSelection,
    required this.isOrdering,
    required this.onDetailTap,
    required this.onContinueTap,
  });

  final PickupController controller;
  final Map<String, AgentRouteInfo> routeInfoByAgent;
  final bool hasSelection;
  final bool isOrdering;
  final VoidCallback onDetailTap;
  final Future<void> Function() onContinueTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D4D4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih Agen',
                    style: TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _PaymentModeBadge(category: controller.selectedCategory),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: controller.agents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final agent = controller.agents[index];
                final isSelected = controller.selectedAgentId == agent.id;
                return _AgentTile(
                  agent: agent,
                  routeInfo: routeInfoByAgent[agent.id],
                  isSelected: isSelected,
                  paymentMode: controller.paymentMode,
                  onTap: () => controller.selectAgent(agent.id),
                );
              },
            ),
          ),
          _PickupActionBar(
            hasSelection: hasSelection,
            isOrdering: isOrdering,
            onDetailTap: onDetailTap,
            onContinueTap: onContinueTap,
          ),
        ],
      ),
    );
  }
}

class _PickupActionBar extends StatelessWidget {
  const _PickupActionBar({
    required this.hasSelection,
    required this.isOrdering,
    required this.onDetailTap,
    required this.onContinueTap,
  });

  final bool hasSelection;
  final bool isOrdering;
  final VoidCallback onDetailTap;
  final Future<void> Function() onContinueTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AnaboolColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: hasSelection ? onDetailTap : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AnaboolColors.brown,
                  side: BorderSide(
                    color: hasSelection
                        ? AnaboolColors.brown
                        : AnaboolColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.person_search_rounded, size: 20),
                label: const Text(
                  'Lihat Agent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: hasSelection && !isOrdering ? onContinueTap : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AnaboolColors.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isOrdering
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentModeBadge extends StatelessWidget {
  const _PaymentModeBadge({required this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    final isFertilizer = category == 'pupuk';
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFertilizer ? Icons.star_rounded : Icons.payments_outlined,
            size: 16,
            color: AnaboolColors.brown,
          ),
          const SizedBox(width: 6),
          Text(
            isFertilizer ? 'Poin' : 'Harga',
            style: const TextStyle(
              color: AnaboolColors.brown,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentTile extends StatelessWidget {
  const _AgentTile({
    required this.agent,
    required this.routeInfo,
    required this.isSelected,
    required this.paymentMode,
    required this.onTap,
  });

  final PickupAgent agent;
  final AgentRouteInfo? routeInfo;
  final bool isSelected;
  final String paymentMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1E7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AnaboolColors.brown
                : AnaboolColors.border.withValues(alpha: 0.35),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x22A64700)
                  : const Color(0x0F000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AnaboolColors.peach.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const ClipOval(
                child: DesignImage(
                  asset: HomeAssets.pickupCat,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AnaboolColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${routeInfo?.distanceLabel ?? agent.distanceLabel} | ${routeInfo?.etaLabel ?? 'ETA dihitung'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AnaboolColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AnaboolColors.header, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        agent.rating?.toStringAsFixed(1) ?? '-',
                        style: const TextStyle(
                          color: AnaboolColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              paymentMode == 'meowpoint'
                  ? agent.meowpointsLabel
                  : agent.priceLabelIdr,
              style: const TextStyle(
                color: AnaboolColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AnaboolColors.brown : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isSelected ? AnaboolColors.brown : AnaboolColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentHeroCard extends StatelessWidget {
  const _AgentHeroCard({required this.agent, required this.routeInfo});

  final PickupAgent agent;
  final AgentRouteInfo? routeInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnaboolColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AnaboolColors.peach.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const ClipOval(
                  child: DesignImage(
                    asset: HomeAssets.pickupCat,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
                      style: const TextStyle(
                        color: AnaboolColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      agent.serviceType,
                      style: const TextStyle(
                        color: AnaboolColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricPill(
                icon: Icons.two_wheeler_rounded,
                label: agent.vehicleName ?? '-',
              ),
              const SizedBox(width: 8),
              _MetricPill(
                icon: Icons.confirmation_number_rounded,
                label: agent.plateNumber ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetricPill(
                icon: Icons.route_rounded,
                label: routeInfo?.distanceLabel ?? agent.distanceLabel,
              ),
              const SizedBox(width: 8),
              _MetricPill(
                icon: Icons.schedule_rounded,
                label: routeInfo?.etaLabel ?? 'ETA dihitung',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AnaboolColors.brown, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AnaboolColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AnaboolColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AnaboolColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class AgentRouteInfo {
  const AgentRouteInfo({
    required this.point,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routePoints,
    required this.isFromOsrm,
  });

  factory AgentRouteInfo.fallback(LatLng userPoint, LatLng agentPoint) {
    final distance =
        const Distance().as(LengthUnit.Meter, userPoint, agentPoint);
    final seconds = (distance / 450 * 60).round().clamp(240, 1800).toInt();
    return AgentRouteInfo(
      point: agentPoint,
      distanceMeters: distance.round(),
      durationSeconds: seconds,
      routePoints: [agentPoint, userPoint],
      isFromOsrm: false,
    );
  }

  final LatLng point;
  final int distanceMeters;
  final int durationSeconds;
  final List<LatLng> routePoints;
  final bool isFromOsrm;

  PickupRouteSnapshot toSnapshot(LatLng userPoint) {
    return PickupRouteSnapshot(
      userPoint: userPoint,
      agentPoint: point,
      routePoints: routePoints,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      isFromOsrm: isFromOsrm,
    );
  }

  String get etaLabel {
    final minutes = (durationSeconds / 60).ceil().clamp(1, 99).toInt();
    return '$minutes menit';
  }

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }
}

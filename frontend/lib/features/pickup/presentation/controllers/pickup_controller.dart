import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/pickup_agent.dart';
import '../../domain/entities/pickup_order.dart';

class PickupRouteSnapshot {
  const PickupRouteSnapshot({
    required this.userPoint,
    required this.agentPoint,
    required this.routePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.isFromOsrm,
  });

  final LatLng userPoint;
  final LatLng agentPoint;
  final List<LatLng> routePoints;
  final int distanceMeters;
  final int durationSeconds;
  final bool isFromOsrm;

  int get etaMinutes => (durationSeconds / 60).ceil().clamp(1, 99).toInt();

  String get etaLabel => '$etaMinutes menit';

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }
}

/// In-memory controller for the pickup feature.
///
/// Uses hardcoded sample data for MVP / demo. The backend integration
/// with Supabase can be plugged in later without changing the UI layer.
class PickupController extends ChangeNotifier {
  PickupController();

  // ──────────────────────────── State ────────────────────────────

  /// 'kotoran' or 'pupuk'
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  /// 'price' or 'meowpoint'
  String _paymentMode = 'price';
  String get paymentMode => _paymentMode;

  /// Currently selected agent ID.
  String? _selectedAgentId;
  String? get selectedAgentId => _selectedAgentId;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOrdering = false;
  bool get isOrdering => _isOrdering;

  PickupOrder? _activeOrder;
  PickupOrder? get activeOrder => _activeOrder;

  PickupRouteSnapshot? _activeRoute;
  PickupRouteSnapshot? get activeRoute => _activeRoute;

  DateTime? _acceptedAt;
  DateTime? _processingAt;
  DateTime? _completedAt;

  /// Simulation timer for auto-advancing order status.
  Timer? _simulationTimer;

  /// Current simulation phase index.
  int _simulationPhase = 0;
  int get simulationPhase => _simulationPhase;

  /// Whether the simulation has completed.
  bool get isOrderComplete =>
      _activeOrder != null &&
      _activeOrder!.statusLogs.every((log) => log.isCompleted);

  String get activeOrderStatusLabel {
    final order = _activeOrder;
    if (order == null) return '';

    PickupStatusLog? latestCompleted;
    for (final log in order.statusLogs) {
      if (log.isCompleted) latestCompleted = log;
    }
    return latestCompleted?.label ?? order.statusLogs.first.label;
  }

  String get activeOrderEtaLabel {
    final order = _activeOrder;
    if (order == null) return '';

    for (final log in order.statusLogs) {
      if (!log.isCompleted && log.subtitle != null) {
        return log.subtitle!;
      }
    }

    for (final log in order.statusLogs.reversed) {
      if (log.isCompleted && log.subtitle != null) {
        return log.subtitle!;
      }
    }
    return '';
  }

  // ──────────────────────────── Actions ────────────────────────────

  void selectCategory(String category) {
    _selectedCategory = category;
    _selectedAgentId = null;
    _paymentMode = category == 'pupuk' ? 'meowpoint' : 'price';
    notifyListeners();
  }

  void togglePaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  void updateActiveRoute(PickupRouteSnapshot route) {
    _activeRoute = route;
    notifyListeners();
  }

  void selectAgent(String agentId) {
    _selectedAgentId = agentId;
    notifyListeners();
  }

  PickupAgent? get selectedAgent {
    if (_selectedAgentId == null) return null;
    try {
      return agents.firstWhere((a) => a.id == _selectedAgentId);
    } catch (_) {
      return null;
    }
  }

  /// Simulate creating an order.
  Future<void> createOrder() async {
    final agent = selectedAgent;
    if (agent == null) return;

    _isOrdering = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final routeEtaMinutes =
        (_activeRoute?.etaMinutes ?? 13).clamp(5, 45).toInt();
    _acceptedAt = now;
    _processingAt = now.add(const Duration(minutes: 2));
    _completedAt = now.add(Duration(minutes: routeEtaMinutes + 2));

    _activeOrder = PickupOrder(
      id: 'order_${now.millisecondsSinceEpoch}',
      agent: PickupOrderAgent(
        name: agent.name,
        avatarUrl: agent.avatarUrl,
        rating: agent.rating,
        vehicleName: agent.vehicleName,
        plateNumber: agent.plateNumber,
        serviceType: agent.serviceType,
      ),
      pickupType: _selectedCategory ?? 'kotoran',
      status: 'accepted',
      statusLogs: [
        PickupStatusLog(
          status: 'accepted',
          label: 'Pesanan Diterima',
          subtitle: 'Diterima ${_formatTime(_acceptedAt!)}',
          timestamp: _acceptedAt,
          isCompleted: true,
        ),
        PickupStatusLog(
          status: 'processing',
          label: 'Pesanan Diproses',
          subtitle: 'Estimasi diproses ${_formatTime(_processingAt!)}',
          timestamp: null,
          isCompleted: false,
        ),
        PickupStatusLog(
          status: 'completed',
          label: 'Pick-up Selesai',
          subtitle: 'Estimasi selesai ${_formatTime(_completedAt!)}',
          timestamp: null,
          isCompleted: false,
        ),
      ],
    );

    _isOrdering = false;
    _simulationPhase = 0;
    notifyListeners();

    // Start order simulation
    _startSimulation();
  }

  /// Start the timer-based simulation that auto-advances status.
  void _startSimulation() {
    _simulationTimer?.cancel();

    // Phase 1: After 5 seconds, move to "processing"
    // Phase 2: After another 8 seconds, move to "completed"
    const phaseDurations = [
      Duration(seconds: 5),
      Duration(seconds: 8),
    ];

    void advancePhase() {
      if (_activeOrder == null) return;

      _simulationPhase++;

      if (_simulationPhase == 1) {
        // Driver is on the way
        _activeOrder = PickupOrder(
          id: _activeOrder!.id,
          agent: _activeOrder!.agent,
          pickupType: _activeOrder!.pickupType,
          status: 'processing',
          statusLogs: [
            _activeOrder!.statusLogs[0], // processing — already completed
            PickupStatusLog(
              status: 'processing',
              label: 'Pesanan Diproses',
              subtitle: 'Diproses ${_formatTime(_processingAt!)}',
              timestamp: _processingAt,
              isCompleted: true,
            ),
            _activeOrder!.statusLogs[2], // completed — still pending
          ],
        );
        notifyListeners();

        // Schedule next phase
        if (_simulationPhase < phaseDurations.length) {
          _simulationTimer = Timer(
            phaseDurations[_simulationPhase],
            advancePhase,
          );
        }
      } else if (_simulationPhase == 2) {
        // Pickup completed
        _activeOrder = PickupOrder(
          id: _activeOrder!.id,
          agent: _activeOrder!.agent,
          pickupType: _activeOrder!.pickupType,
          status: 'completed',
          statusLogs: [
            _activeOrder!.statusLogs[0],
            _activeOrder!.statusLogs[1],
            PickupStatusLog(
              status: 'completed',
              label: 'Pick-up Selesai',
              subtitle: 'Selesai ${_formatTime(_completedAt!)}',
              timestamp: _completedAt,
              isCompleted: true,
            ),
          ],
        );
        notifyListeners();
      }
    }

    _simulationTimer = Timer(phaseDurations[0], advancePhase);
  }

  void reset() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _simulationPhase = 0;
    _selectedCategory = null;
    _selectedAgentId = null;
    _activeOrder = null;
    _activeRoute = null;
    _acceptedAt = null;
    _processingAt = null;
    _completedAt = null;
    _paymentMode = 'price';
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  // ──────────────────────────── Sample Data ────────────────────────────

  List<PickupAgent> get agents {
    return const [
      PickupAgent(
        id: 'agent_1',
        name: 'Nabila Wijaya Putri',
        distanceMeters: 850,
        priceIdr: 9000,
        meowpoints: 3000,
        rating: 4.5,
        vehicleName: 'Jupiter 135 MX',
        plateNumber: 'DK 1326 MQ',
        serviceType: 'Pick-up & Jasa Pembersihan',
        reviewSummary:
            'Respons cepat, petugas rapi, dan pengambilan sesuai waktu.',
        recommendationReasons: [
          'Paling dekat dari titik pengguna',
          'Rutin menangani pickup limbah kucing',
          'Membawa perlengkapan sanitasi standar ANABOOL',
        ],
      ),
      PickupAgent(
        id: 'agent_2',
        name: 'Agen Anabool Sentro',
        distanceMeters: 1200,
        priceIdr: 10000,
        meowpoints: 4500,
        rating: 4.8,
        vehicleName: 'Beat Street',
        plateNumber: 'DK 5678 AB',
        reviewSummary:
            'Banyak ulasan positif untuk komunikasi dan ketepatan jemput.',
        recommendationReasons: [
          'Rating tertinggi di area terdekat',
          'Cocok untuk pickup dengan instruksi khusus',
          'Memiliki riwayat penyelesaian pesanan stabil',
        ],
      ),
      PickupAgent(
        id: 'agent_3',
        name: 'Agen Anabool Dentro',
        distanceMeters: 1650,
        priceIdr: 12000,
        meowpoints: 2000,
        rating: 4.2,
        vehicleName: 'Vario 125',
        plateNumber: 'DK 9012 CD',
        reviewSummary:
            'Direkomendasikan untuk pickup pupuk dan pengemasan ulang.',
        recommendationReasons: [
          'Berpengalaman untuk kategori pupuk',
          'Biaya MeowPoint paling rendah',
          'Area parkir dekat rute utama',
        ],
      ),
      PickupAgent(
        id: 'agent_4',
        name: 'Agen Anabool Utara',
        distanceMeters: 2100,
        priceIdr: 14000,
        meowpoints: 5200,
        rating: 4.6,
        vehicleName: 'Scoopy Prestige',
        plateNumber: 'DK 3372 AN',
        reviewSummary:
            'Disukai pengguna karena pengambilan bersih dan dokumentasi jelas.',
        recommendationReasons: [
          'Alternatif saat agen terdekat sibuk',
          'Menyediakan foto bukti pickup',
          'Komunikasi WhatsApp aktif',
        ],
      ),
    ];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

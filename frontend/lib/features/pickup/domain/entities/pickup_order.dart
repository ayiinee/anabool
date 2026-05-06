/// Represents the current pickup order for the tracking page.
class PickupOrder {
  const PickupOrder({
    required this.id,
    required this.agent,
    required this.pickupType,
    required this.status,
    required this.statusLogs,
  });

  final String id;
  final PickupOrderAgent agent;
  final String pickupType;
  final String status;
  final List<PickupStatusLog> statusLogs;
}

class PickupOrderAgent {
  const PickupOrderAgent({
    required this.name,
    this.avatarUrl,
    this.rating,
    this.vehicleName,
    this.plateNumber,
    this.serviceType = 'Pick-up & Jasa Pembersihan',
    this.badgeLabel = 'Agen Anabool',
  });

  final String name;
  final String? avatarUrl;
  final double? rating;
  final String? vehicleName;
  final String? plateNumber;
  final String serviceType;
  final String badgeLabel;
}

class PickupStatusLog {
  const PickupStatusLog({
    required this.status,
    required this.label,
    this.subtitle,
    this.timestamp,
    this.isCompleted = false,
  });

  final String status;
  final String label;
  final String? subtitle;
  final DateTime? timestamp;
  final bool isCompleted;
}

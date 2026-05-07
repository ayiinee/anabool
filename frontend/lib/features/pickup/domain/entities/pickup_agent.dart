/// Represents a nearby pickup agent (Agen Anabool) that can be selected.
class PickupAgent {
  const PickupAgent({
    required this.id,
    required this.name,
    required this.distanceMeters,
    this.priceIdr,
    this.meowpoints,
    this.avatarUrl,
    this.rating,
    this.vehicleName,
    this.plateNumber,
    this.serviceType = 'Pick-up & Jasa Pembersihan',
    this.reviewSummary,
    this.recommendationReasons = const [],
  });

  final String id;
  final String name;
  final int distanceMeters;
  final int? priceIdr;
  final int? meowpoints;
  final String? avatarUrl;
  final double? rating;
  final String? vehicleName;
  final String? plateNumber;
  final String serviceType;
  final String? reviewSummary;
  final List<String> recommendationReasons;

  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters meter';
  }

  String get priceLabelIdr {
    if (priceIdr == null) return '-';
    final formatted = priceIdr.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
    return 'Rp$formatted';
  }

  String get meowpointsLabel {
    if (meowpoints == null) return '-';
    final formatted = meowpoints.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
    return '$formatted XP';
  }
}

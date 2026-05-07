class LitterBox {
  const LitterBox({
    required this.id,
    required this.userId,
    required this.catId,
    required this.locationLabel,
    required this.boxType,
    required this.litterType,
    required this.boxCount,
    required this.cleaningFrequency,
    required this.lastCleanedLabel,
    required this.status,
    required this.lastCleanedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String catId;
  final String locationLabel;
  final String boxType;
  final String litterType;
  final int boxCount;
  final String cleaningFrequency;
  final String lastCleanedLabel;
  final String status;
  final DateTime? lastCleanedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LitterBox copyWith({
    String? id,
    String? userId,
    String? catId,
    String? locationLabel,
    String? boxType,
    String? litterType,
    int? boxCount,
    String? cleaningFrequency,
    String? lastCleanedLabel,
    String? status,
    DateTime? lastCleanedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LitterBox(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      catId: catId ?? this.catId,
      locationLabel: locationLabel ?? this.locationLabel,
      boxType: boxType ?? this.boxType,
      litterType: litterType ?? this.litterType,
      boxCount: boxCount ?? this.boxCount,
      cleaningFrequency: cleaningFrequency ?? this.cleaningFrequency,
      lastCleanedLabel: lastCleanedLabel ?? this.lastCleanedLabel,
      status: status ?? this.status,
      lastCleanedAt: lastCleanedAt ?? this.lastCleanedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LitterBoxStatus {
  const LitterBoxStatus({
    required this.cleanlinessStatus,
    required this.peeCount,
    required this.poopCount,
    required this.alertMessage,
    required this.abnormalPatternDetected,
  });

  final String cleanlinessStatus;
  final int peeCount;
  final int poopCount;
  final String? alertMessage;
  final bool abnormalPatternDetected;
}

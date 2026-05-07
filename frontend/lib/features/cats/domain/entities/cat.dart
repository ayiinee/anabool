class Cat {
  const Cat({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.lifeStage,
    required this.gender,
    required this.avatarAsset,
    required this.peeFrequencyPerDay,
    required this.poopFrequencyPerDay,
    required this.healthNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final String lifeStage;
  final String gender;
  final String avatarAsset;
  final int peeFrequencyPerDay;
  final int poopFrequencyPerDay;
  final String healthNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cat copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? breed,
    String? lifeStage,
    String? gender,
    String? avatarAsset,
    int? peeFrequencyPerDay,
    int? poopFrequencyPerDay,
    String? healthNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cat(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      lifeStage: lifeStage ?? this.lifeStage,
      gender: gender ?? this.gender,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      peeFrequencyPerDay: peeFrequencyPerDay ?? this.peeFrequencyPerDay,
      poopFrequencyPerDay: poopFrequencyPerDay ?? this.poopFrequencyPerDay,
      healthNotes: healthNotes ?? this.healthNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

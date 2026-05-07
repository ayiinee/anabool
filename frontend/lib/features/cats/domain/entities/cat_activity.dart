enum CatActivityType {
  pee,
  poop,
  clean,
  note,
}

class CatActivity {
  const CatActivity({
    required this.id,
    required this.catId,
    required this.litterBoxId,
    required this.type,
    required this.notes,
    required this.recordedAt,
    required this.createdAt,
  });

  final String id;
  final String catId;
  final String? litterBoxId;
  final CatActivityType type;
  final String notes;
  final DateTime recordedAt;
  final DateTime createdAt;

  String get label {
    switch (type) {
      case CatActivityType.pee:
        return 'Pipis';
      case CatActivityType.poop:
        return 'Pup';
      case CatActivityType.clean:
        return 'Dibersihkan';
      case CatActivityType.note:
        return 'Catatan';
    }
  }
}

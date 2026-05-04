class WasteClass {
  const WasteClass({
    required this.category,
    this.riskLevel,
  });

  final String category;
  final String? riskLevel;

  String get displayName {
    final normalized = category.trim();
    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class MarketplaceSeller {
  final String id;
  final String displayName;
  final String avatarUrl;

  const MarketplaceSeller({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
  });

  factory MarketplaceSeller.fromMap(Map<String, dynamic> map) {
    return MarketplaceSeller(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? 'Unknown',
      avatarUrl: map['avatar_url'] as String? ?? '',
    );
  }
}

class MarketplaceCategory {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String iconUrl;
  final int displayOrder;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconUrl,
    required this.displayOrder,
  });

  factory MarketplaceCategory.fromMap(Map<String, dynamic> map) {
    return MarketplaceCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
      description: map['description'] as String? ?? '',
      iconUrl: map['icon_url'] as String? ?? '',
      displayOrder: map['display_order'] as int? ?? 0,
    );
  }
}

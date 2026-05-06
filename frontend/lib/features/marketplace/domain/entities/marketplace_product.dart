import 'marketplace_category.dart';
import 'marketplace_seller.dart';
import 'marketplace_review.dart';

class MarketplaceProduct {
  final String id;
  final String sellerId;
  final String categoryId;
  final String name;
  final String description;
  final int priceIdr;
  final int stock;
  final String unit;
  final String waNumber;
  final String waTemplate;
  final double avgRating;
  final MarketplaceSeller? seller;
  final MarketplaceCategory? category;
  final List<String> imageUrls;
  final List<MarketplaceReview> reviews;

  const MarketplaceProduct({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.priceIdr,
    required this.stock,
    required this.unit,
    required this.waNumber,
    required this.waTemplate,
    required this.avgRating,
    this.seller,
    this.category,
    this.imageUrls = const [],
    this.reviews = const [],
  });

  factory MarketplaceProduct.fromMap(Map<String, dynamic> map) {
    var images = <String>[];
    if (map['images'] != null) {
      images = (map['images'] as List).map((i) => i['image_url'].toString()).toList();
    }

    var reviewsList = <MarketplaceReview>[];
    if (map['reviews'] != null) {
      reviewsList = (map['reviews'] as List).map((r) => MarketplaceReview.fromMap(r)).toList();
    }

    return MarketplaceProduct(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      priceIdr: map['price_idr'] as int,
      stock: map['stock'] as int,
      unit: map['unit'] as String? ?? '',
      waNumber: map['wa_number'] as String? ?? '',
      waTemplate: map['wa_template'] as String? ?? '',
      avgRating: (map['avg_rating'] ?? 0.0).toDouble(),
      seller: map['seller'] != null ? MarketplaceSeller.fromMap(map['seller']) : null,
      category: map['category'] != null ? MarketplaceCategory.fromMap(map['category']) : null,
      imageUrls: images,
      reviews: reviewsList,
    );
  }
}

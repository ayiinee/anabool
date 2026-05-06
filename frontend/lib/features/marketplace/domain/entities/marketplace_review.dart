import 'marketplace_seller.dart';

class MarketplaceReview {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String body;
  final DateTime createdAt;
  final MarketplaceSeller? user; // Reusing seller model for user display info

  const MarketplaceReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.body,
    required this.createdAt,
    this.user,
  });

  factory MarketplaceReview.fromMap(Map<String, dynamic> map) {
    return MarketplaceReview(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      userId: map['user_id'] as String,
      rating: map['rating'] as int,
      body: map['body'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      user: map['user'] != null ? MarketplaceSeller.fromMap(map['user']) : null,
    );
  }
}

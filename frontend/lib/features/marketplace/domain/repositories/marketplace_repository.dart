import '../entities/marketplace_category.dart';
import '../entities/marketplace_product.dart';
import '../entities/marketplace_review.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceCategory>> getCategories();
  Future<List<MarketplaceProduct>> getProducts({
    String? query,
    String? categorySlug,
  });
  Future<MarketplaceProduct> getProductDetail(String productId);
  Future<List<MarketplaceReview>> getProductReviews(String productId);
}

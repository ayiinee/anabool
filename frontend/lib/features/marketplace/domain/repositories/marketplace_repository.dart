import '../entities/marketplace_category.dart';
import '../entities/marketplace_product.dart';
import '../entities/marketplace_review.dart';
import '../entities/marketplace_whatsapp_order.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceCategory>> getCategories();
  Future<List<MarketplaceProduct>> getProducts({
    String? query,
    String? categorySlug,
  });
  Future<MarketplaceProduct> getProductDetail(String productId);
  Future<List<MarketplaceReview>> getProductReviews(String productId);
  Future<MarketplaceWhatsAppOrder> createWhatsAppOrder(
    String productId, {
    String? templateMessage,
  });
}

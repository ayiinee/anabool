import '../../domain/entities/marketplace_category.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/marketplace_review.dart';
import '../../domain/entities/marketplace_whatsapp_order.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl({
    required MarketplaceRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final MarketplaceRemoteDatasource _remoteDatasource;

  @override
  Future<List<MarketplaceCategory>> getCategories() {
    return _remoteDatasource.getCategories();
  }

  @override
  Future<List<MarketplaceProduct>> getProducts({
    String? query,
    String? categorySlug,
  }) {
    return _remoteDatasource.getProducts(
      query: query,
      categorySlug: categorySlug,
    );
  }

  @override
  Future<MarketplaceProduct> getProductDetail(String productId) {
    return _remoteDatasource.getProductDetail(productId);
  }

  @override
  Future<List<MarketplaceReview>> getProductReviews(String productId) {
    return _remoteDatasource.getProductReviews(productId);
  }

  @override
  Future<MarketplaceWhatsAppOrder> createWhatsAppOrder(
    String productId, {
    String? templateMessage,
  }) {
    return _remoteDatasource.createWhatsAppOrder(
      productId,
      templateMessage: templateMessage,
    );
  }
}

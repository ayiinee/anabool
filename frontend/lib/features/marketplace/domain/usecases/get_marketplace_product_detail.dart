import '../entities/marketplace_product.dart';
import '../repositories/marketplace_repository.dart';

class GetMarketplaceProductDetail {
  final MarketplaceRepository repository;

  GetMarketplaceProductDetail(this.repository);

  Future<MarketplaceProduct> call(String productId) async {
    return await repository.getProductDetail(productId);
  }
}

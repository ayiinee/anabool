import '../entities/marketplace_category.dart';
import '../entities/marketplace_product.dart';
import '../repositories/marketplace_repository.dart';

class MarketplaceCatalog {
  final List<MarketplaceCategory> categories;
  final List<MarketplaceProduct> products;

  const MarketplaceCatalog({
    required this.categories,
    required this.products,
  });
}

class GetMarketplaceCatalog {
  final MarketplaceRepository repository;

  GetMarketplaceCatalog(this.repository);

  Future<MarketplaceCatalog> call({String? query, String? categorySlug}) async {
    final categories = await repository.getCategories();
    final products = await repository.getProducts(query: query, categorySlug: categorySlug);
    
    return MarketplaceCatalog(
      categories: categories,
      products: products,
    );
  }
}

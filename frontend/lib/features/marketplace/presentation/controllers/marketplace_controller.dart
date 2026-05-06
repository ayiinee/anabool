import 'package:flutter/foundation.dart';

import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../domain/entities/marketplace_category.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/usecases/get_marketplace_catalog.dart';
import '../../domain/usecases/get_marketplace_product_detail.dart';

class MarketplaceController extends ChangeNotifier {
  MarketplaceController({
    required GetMarketplaceCatalog getMarketplaceCatalog,
    required GetMarketplaceProductDetail getMarketplaceProductDetail,
  })  : _getMarketplaceCatalog = getMarketplaceCatalog,
        _getMarketplaceProductDetail = getMarketplaceProductDetail;

  factory MarketplaceController.create() {
    final repository = _sharedRepository;
    return MarketplaceController(
      getMarketplaceCatalog: GetMarketplaceCatalog(repository),
      getMarketplaceProductDetail: GetMarketplaceProductDetail(repository),
    );
  }

  static final MarketplaceRepository _sharedRepository = MarketplaceRepositoryImpl(
    remoteDatasource: MarketplaceRemoteDatasourceImpl(),
  );

  final GetMarketplaceCatalog _getMarketplaceCatalog;
  final GetMarketplaceProductDetail _getMarketplaceProductDetail;

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategorySlug = 'semua';

  List<MarketplaceCategory> categories = [];
  List<MarketplaceProduct> products = [];
  MarketplaceProduct? selectedProduct;

  List<MarketplaceProduct> get filteredProducts {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    return products.where((product) {
      final matchesCategory = selectedCategorySlug == 'semua' ||
          product.category?.slug == selectedCategorySlug;
      final categoryName = product.category?.name.toLowerCase() ?? '';
      final matchesQuery = normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery) ||
          categoryName.contains(normalizedQuery);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final catalog = await _getMarketplaceCatalog();
      categories = [
        const MarketplaceCategory(
          id: 'semua',
          name: 'Semua',
          slug: 'semua',
          description: '',
          iconUrl: '',
          displayOrder: 0,
        ),
        ...catalog.categories,
      ];
      products = catalog.products;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String productId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedProduct = await _getMarketplaceProductDetail(productId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void selectCategory(String slug) {
    selectedCategorySlug = slug;
    notifyListeners();
  }
}

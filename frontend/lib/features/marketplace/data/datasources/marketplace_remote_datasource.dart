import 'package:dio/dio.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/marketplace_category.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/marketplace_review.dart';

abstract class MarketplaceRemoteDatasource {
  Future<List<MarketplaceCategory>> getCategories();
  Future<List<MarketplaceProduct>> getProducts({
    String? query,
    String? categorySlug,
  });
  Future<MarketplaceProduct> getProductDetail(String productId);
  Future<List<MarketplaceReview>> getProductReviews(String productId);
}

class MarketplaceRemoteDatasourceImpl implements MarketplaceRemoteDatasource {
  MarketplaceRemoteDatasourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<List<MarketplaceCategory>> getCategories() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/api/v1/marketplace/categories');
      final data = response.data['data'] as List;
      return data.map((e) => MarketplaceCategory.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kategori');
    }
  }

  @override
  Future<List<MarketplaceProduct>> getProducts({
    String? query,
    String? categorySlug,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (categorySlug != null && categorySlug.isNotEmpty) {
        queryParams['category_slug'] = categorySlug;
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/v1/marketplace/products',
        queryParameters: queryParams,
      );
      
      final data = response.data['data']['items'] as List;
      return data.map((e) => MarketplaceProduct.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat produk');
    }
  }

  @override
  Future<MarketplaceProduct> getProductDetail(String productId) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/api/v1/marketplace/products/$productId');
      return MarketplaceProduct.fromMap(response.data['data']);
    } catch (e) {
      throw Exception('Gagal memuat detail produk');
    }
  }

  @override
  Future<List<MarketplaceReview>> getProductReviews(String productId) async {
    // Note: The backend route /api/v1/marketplace/products/{product_id}/reviews only has POST.
    // However, the product detail might include reviews. Wait, does it? 
    // If not, we might need to mock or change the structure.
    return []; // Placeholder for now, we'll check backend later
  }
}

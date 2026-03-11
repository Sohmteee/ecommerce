import 'package:ecommerce/core/network/api_endpoints.dart';
import 'package:ecommerce/core/network/dio_client.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/domain/models/product_category.dart';

/// Data source responsible for fetching product-related data from the remote API.
class ProductRemoteDataSource {
  final DioClient _client;

  ProductRemoteDataSource(this._client);

  /// Fetches a paginated list of products.
  ///
  /// [limit] specifies the number of items per page.
  /// [skip] specifies the number of items to skip.
  /// [sortBy] field name to sort by.
  /// [order] 'asc' or 'desc'.
  Future<ProductResponse> getProducts({
    int limit = 30,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.products,
        queryParameters: {
          'limit': limit,
          'skip': skip,
          'sortBy': ?sortBy,
          'order': ?order,
        },
      );
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches detailed information for a single product by its [id].
  Future<Product> getProductDetails(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.productDetails(id));
      return Product.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Searches for products matching the given [query].
  Future<ProductResponse> searchProducts(String query) async {
    try {
      final response = await _client.get(
        ApiEndpoints.searchProducts,
        queryParameters: {'q': query},
      );
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches products belonging to a specific [category].
  Future<ProductResponse> getProductsByCategory(String category) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.productByCategory}/$category',
      );
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a list of detailed product categories.
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.categories);
      return (response.data as List<dynamic>)
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a simple list of category names (Strings).
  Future<List<String>> getCategoryList() async {
    try {
      final response = await _client.get(ApiEndpoints.categoryList);
      return (response.data as List<dynamic>).map((e) => e as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Adds a new product to the database.
  ///
  /// [productData] contains the field-value pairs for the new product.
  Future<Product> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.addProduct,
        data: productData,
      );
      return Product.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing product with the provided [productData].
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiEndpoints.updateProduct(id),
        data: productData,
      );
      return Product.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a product by its [id].
  Future<Product> deleteProduct(int id) async {
    try {
      final response = await _client.dio.delete(ApiEndpoints.deleteProduct(id));
      return Product.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/domain/models/product_category.dart';

/// Interface for product-related data operations.
abstract class ProductRepository {
  /// Fetches a paginated list of products.
  Future<ProductResponse> getProducts({
    int limit = 30,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  /// Fetches detailed information for a single product by its [id].
  Future<Product> getProductDetails(int id);

  /// Searches for products matching the given [query].
  Future<ProductResponse> searchProducts(String query);

  /// Fetches products belonging to a specific [category].
  Future<ProductResponse> getProductsByCategory(String category);

  /// Fetches a list of detailed product categories.
  Future<List<ProductCategory>> getCategories();

  /// Fetches a simple list of category names.
  Future<List<String>> getCategoryList();

  /// Adds a new product to the remote data source.
  Future<Product> addProduct(Map<String, dynamic> productData);

  /// Updates an existing product by [id] with [productData].
  Future<Product> updateProduct(int id, Map<String, dynamic> productData);

  /// Deletes a product by its [id].
  Future<Product> deleteProduct(int id);
}

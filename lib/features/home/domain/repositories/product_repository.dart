import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/domain/models/product_category.dart';

abstract class ProductRepository {
  Future<ProductResponse> getProducts({
    int limit = 30,
    int skip = 0,
    String? sortBy,
    String? order,
  });
  Future<Product> getProductDetails(int id);
  Future<ProductResponse> searchProducts(String query);
  Future<ProductResponse> getProductsByCategory(String category);
  Future<List<ProductCategory>> getCategories();
  Future<List<String>> getCategoryList();
  Future<Product> addProduct(Map<String, dynamic> productData);
  Future<Product> updateProduct(int id, Map<String, dynamic> productData);
  Future<Product> deleteProduct(int id);
}

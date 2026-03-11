import 'package:ecommerce/features/home/data/data_sources/product_remote_data_source.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/domain/models/product_category.dart';
import 'package:ecommerce/features/home/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProductResponse> getProducts({
    int limit = 30,
    int skip = 0,
    String? sortBy,
    String? order,
  }) {
    return _remoteDataSource.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }

  @override
  Future<Product> getProductDetails(int id) {
    return _remoteDataSource.getProductDetails(id);
  }

  @override
  Future<ProductResponse> searchProducts(String query) {
    return _remoteDataSource.searchProducts(query);
  }

  @override
  Future<ProductResponse> getProductsByCategory(String category) {
    return _remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<List<ProductCategory>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<List<String>> getCategoryList() {
    return _remoteDataSource.getCategoryList();
  }

  @override
  Future<Product> addProduct(Map<String, dynamic> productData) {
    return _remoteDataSource.addProduct(productData);
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> productData) {
    return _remoteDataSource.updateProduct(id, productData);
  }

  @override
  Future<Product> deleteProduct(int id) {
    return _remoteDataSource.deleteProduct(id);
  }
}

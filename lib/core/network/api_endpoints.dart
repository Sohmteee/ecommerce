class ApiEndpoints {
  static const String baseUrl = 'https://dummyjson.com';
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryList = '/products/category-list';
  static const String productByCategory = '/products/category';
  static const String addProduct = '/products/add';

  static String productDetails(int id) => '/products/$id';
  static String updateProduct(int id) => '/products/$id';
  static String deleteProduct(int id) => '/products/$id';
}

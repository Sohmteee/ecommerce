/// Contains all API endpoint paths used in the application.
class ApiEndpoints {
  /// The base URL for the DummyJSON API.
  static const String baseUrl = 'https://dummyjson.com';

  /// Endpoint to fetch all products.
  static const String products = '/products';

  /// Endpoint to search for products.
  static const String searchProducts = '/products/search';

  /// Endpoint to fetch all product categories.
  static const String categories = '/products/categories';

  /// Endpoint to fetch a simple list of category names.
  static const String categoryList = '/products/category-list';

  /// Base path for fetching products by category.
  static const String productByCategory = '/products/category';

  /// Endpoint to add a new product.
  static const String addProduct = '/products/add';

  /// Returns the endpoint path for a specific product's details.
  static String productDetails(int id) => '/products/$id';

  /// Returns the endpoint path for updating a specific product.
  static String updateProduct(int id) => '/products/$id';

  /// Returns the endpoint path for deleting a specific product.
  static String deleteProduct(int id) => '/products/$id';
}

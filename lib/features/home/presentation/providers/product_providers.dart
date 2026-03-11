import 'package:ecommerce/core/network/dio_client.dart';
import 'package:ecommerce/features/home/data/data_sources/product_remote_data_source.dart';
import 'package:ecommerce/features/home/data/repositories/product_repository_impl.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available fields for sorting products.
enum SortBy { title, price, rating }

/// Order of sorting.
enum SortOrder { asc, desc }

/// Represents a combination of [SortBy] and [SortOrder].
class SortOption {
  final SortBy sortBy;
  final SortOrder order;

  const SortOption({required this.sortBy, required this.order});

  /// Returns the enum name as a string for API query parameters.
  String get sortByString => sortBy.name;
  /// Returns the order name as a string for API query parameters.
  String get orderString => order.name;
}

/// Provider for the singleton [DioClient].
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

/// Provider for [ProductRemoteDataSource].
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ProductRemoteDataSource(client);
});

/// Provider for [ProductRepository].
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

/// Notifier for managing the global search query.
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(SearchQuery.new);

/// Notifier for managing the active [SortOption].
class SortNotifier extends Notifier<SortOption?> {
  @override
  SortOption? build() => null;
  
  void update(SortOption? option) => state = option;
}

final sortProvider = NotifierProvider<SortNotifier, SortOption?>(SortNotifier.new);

/// Notifier for managing the currently selected product category.
class SelectedCategory extends Notifier<String?> {
  @override
  String? build() => null;
  
  void update(String? category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategory, String?>(SelectedCategory.new);

/// Main notifier for fetching and managing the list of products.
/// 
/// It reacts to changes in search query, sort options, and selected category.
class ProductsNotifier extends AsyncNotifier<ProductResponse> {
  @override
  Future<ProductResponse> build() async {
    final repository = ref.watch(productRepositoryProvider);
    final query = ref.watch(searchQueryProvider);
    final sort = ref.watch(sortProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (query.isNotEmpty) {
      return repository.searchProducts(query);
    }

    if (selectedCategory != null) {
      return repository.getProductsByCategory(selectedCategory);
    }

    return repository.getProducts(
      sortBy: sort?.sortByString,
      order: sort?.orderString,
    );
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    final repository = ref.read(productRepositoryProvider);
    final newProduct = await repository.addProduct(productData);
    
    // Optimistically/Locally update the state since API won't persist
    state = AsyncData(state.value!.copyWith(
      products: [newProduct, ...state.value!.products],
      total: state.value!.total + 1,
    ));
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    final repository = ref.read(productRepositoryProvider);
    final updatedProduct = await repository.updateProduct(id, productData);
    
    // Locally update the state
    state = AsyncData(state.value!.copyWith(
      products: state.value!.products.map((p) => p.id == id ? updatedProduct : p).toList(),
    ));
  }

  Future<void> deleteProduct(int id) async {
    final repository = ref.read(productRepositoryProvider);
    await repository.deleteProduct(id);
    
    // Locally update the state
    state = AsyncData(state.value!.copyWith(
      products: state.value!.products.where((p) => p.id != id).toList(),
      total: state.value!.total - 1,
    ));
  }
}


/// Provider for the [ProductsNotifier] and the list of products.
final productsProvider = AsyncNotifierProvider<ProductsNotifier, ProductResponse>(ProductsNotifier.new);

/// Provider for specific product details by ID.
final productDetailsProvider = FutureProvider.family<Product, int>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductDetails(id);
});

/// Provider for the list of available category names.
final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategoryList();
});

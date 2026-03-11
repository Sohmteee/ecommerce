import 'dart:ui' as ui;

import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/presentation/providers/product_providers.dart';
import 'package:ecommerce/features/home/presentation/screens/product_detail_screen.dart';
import 'package:ecommerce/features/home/presentation/widgets/add_edit_product_dialog.dart';
import 'package:ecommerce/features/home/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: GlassContainer(
          borderRadius: BorderRadius.circular(12),
          opacity: 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).update(value),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
              icon: Icon(
                Iconsax.search_normal,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Iconsax.sort),
            onSelected: (option) =>
                ref.read(sortProvider.notifier).update(option),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Default')),
              const PopupMenuItem(
                value: SortOption(sortBy: SortBy.price, order: SortOrder.asc),
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: SortOption(sortBy: SortBy.price, order: SortOrder.desc),
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: SortOption(sortBy: SortBy.rating, order: SortOrder.desc),
                child: Text('Top Rated'),
              ),
              const PopupMenuItem(
                value: SortOption(sortBy: SortBy.title, order: SortOrder.asc),
                child: Text('A - Z'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: productsAsync.when(
          data: (ProductResponse response) => _buildBody(response.products),
          loading: () => Skeletonizer(
            enabled: true,
            child: _buildBody(
              List.generate(
                6,
                (index) => Product(
                  id: index,
                  title: 'Loading Product Name',
                  description: 'Description placeholder for skeleton effect',
                  category: 'category',
                  price: 99.99,
                  discountPercentage: 0,
                  rating: 0,
                  stock: 0,
                  tags: [],
                  sku: '',
                  weight: 0,
                  dimensions: Dimensions(width: 0, height: 0, depth: 0),
                  warrantyInformation: '',
                  shippingInformation: '',
                  availabilityStatus: '',
                  reviews: [],
                  returnPolicy: '',
                  minimumOrderQuantity: 0,
                  meta: Meta(
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    barcode: '',
                    qrCode: '',
                  ),
                  thumbnail: '',
                  images: [],
                ),
              ),
            ),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.danger, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $err'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(productsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<Product> products) {
    return Column(
      children: [
        const SizedBox(height: 110),
        _buildCategorySelector(),
        const SizedBox(height: 12),
        Expanded(child: _buildProductGrid(products)),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(categoryListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        final allCategories = ['All', ...categories];
        return SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected =
                  (category == 'All' && selectedCategory == null) ||
                  (category == selectedCategory);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected ? Colors.deepPurple : Colors.white10,
                  opacity: isSelected ? 0.3 : 0.05,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .update(category == 'All' ? null : category);
                      },
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, _) => Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showAddEditDialog({Product? product}) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => AddEditProductDialog(product: product),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => DeleteConfirmationDialog(product: product),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final currencyFormat = NumberFormat.simpleCurrency();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          ),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(8),
            opacity: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'product_${product.id}',
                            child: product.thumbnail.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.network(
                                      product.thumbnail,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(Iconsax.image,
                                    size: 40, color: Colors.white24),
                          ),
                        ),
                      ),
                      // Edit/Delete small buttons
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Row(
                          children: [
                            _buildActionIcon(
                              Iconsax.edit_2,
                              Colors.blue.shade300,
                              () => _showAddEditDialog(product: product),
                            ),
                            const SizedBox(width: 4),
                            _buildActionIcon(
                              Iconsax.trash,
                              Colors.red.shade300,
                              () => _showDeleteDialog(product),
                            ),
                          ],
                        ),
                      ),
                      // Rating Badge
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          borderRadius: BorderRadius.circular(8),
                          opacity: 0.2,
                          child: Row(
                            children: [
                              const Icon(Iconsax.star1, size: 10, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (product.discountPercentage > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discountPercentage.round()}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.deepPurple.shade300,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(product.price),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          // Quick Add
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GlassContainer(
      opacity: 0.1,
      shape: BoxShape.circle,
      padding: const EdgeInsets.all(6),
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

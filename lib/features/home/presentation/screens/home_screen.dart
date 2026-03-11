import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/presentation/providers/product_providers.dart';
import 'package:ecommerce/features/home/presentation/screens/product_detail_screen.dart';
import 'package:ecommerce/features/home/presentation/widgets/add_edit_product_dialog.dart';
import 'package:ecommerce/features/home/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          borderRadius: BorderRadius.circular(12.r),
          opacity: 0.05,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).update(value),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              icon: Icon(
                Iconsax.search_normal,
                size: 20.sp,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14.sp,
            ),
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
                Icon(Iconsax.danger, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Error: $err', style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 8.h),
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
        SizedBox(height: 110.h),
        _buildCategorySelector(),
        SizedBox(height: 12.h),
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
          height: 50.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected =
                  (category == 'All' && selectedCategory == null) ||
                  (category == selectedCategory);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(25.r),
                  color: isSelected ? Colors.deepPurple : Colors.white10,
                  opacity: isSelected ? 0.3 : 0.05,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          fontSize: 13.sp,
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
    final screenWidth = MediaQuery.of(context).size.width;
    // Dynamically calculate crossAxisCount and childAspectRatio
    int crossAxisCount = screenWidth > 600 ? 3 : 2;
    // Base aspect ratio is adjusted to prevent stretching on wider screens
    double childAspectRatio = screenWidth > 600 ? 0.75 : 0.62;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
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
            borderRadius: BorderRadius.circular(24.r),
            padding: EdgeInsets.all(8.w),
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
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'product_${product.id}',
                            child: product.thumbnail.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: CachedNetworkImage(
                                      imageUrl: product.thumbnail,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Skeletonizer(
                                        enabled: true,
                                        child: Container(color: Colors.white10),
                                      ),
                                    ),
                                  )
                                : Icon(Iconsax.image, size: 40.sp, color: Colors.white24),
                          ),
                        ),
                      ),
                      // Edit/Delete small buttons
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Row(
                          children: [
                            _buildActionIcon(
                              Iconsax.edit_2,
                              Colors.blue.shade300,
                              () => _showAddEditDialog(product: product),
                            ),
                            SizedBox(width: 4.w),
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
                        bottom: 6.h,
                        right: 6.w,
                        child: GlassContainer(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                          borderRadius: BorderRadius.circular(8.r),
                          opacity: 0.2,
                          child: Row(
                            children: [
                              Icon(Iconsax.star1, size: 10.sp, color: Colors.amber),
                              SizedBox(width: 2.w),
                              Text(
                                '${product.rating}',
                                style: TextStyle(
                                  fontSize: 10.sp,
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
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '-${product.discountPercentage.round()}%',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                // Info Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.deepPurple.shade300,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              currencyFormat.format(product.price),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.deepPurple.shade700,
                                fontWeight: FontWeight.w900,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                          // Quick Add
                          Container(
                            height: 32.h,
                            width: 32.w,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
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
      padding: EdgeInsets.all(6.w),
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, size: 14.sp, color: color),
      ),
    );
  }
}

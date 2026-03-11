import 'dart:math' as math;
import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      extendBodyBehindAppBar: true,
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
        child: productAsync.when(
          data: (product) => Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ProductHeaderDelegate(
                      product: product,
                      isDark: isDark,
                      statusBarHeight: MediaQuery.of(context).padding.top,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDetailContent(context, product, isDark),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomAction(context, product, isDark, currencyFormat),
              ),
              // Custom Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: GlassContainer(
                  shape: BoxShape.circle,
                  opacity: 0.1,
                  child: IconButton(
                    icon: const Icon(Iconsax.arrow_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          loading: () => Skeletonizer(
            enabled: true,
            child: SingleChildScrollView(
              child: _buildDetailContent(
                context,
                Product(
                  id: 0,
                  title: 'Loading Product Name',
                  description:
                      'This is a long description placeholder for the skeleton effect to look realistic and cover enough space.',
                  category: 'category',
                  price: 99.99,
                  discountPercentage: 0,
                  rating: 4.5,
                  stock: 10,
                  tags: [],
                  sku: '',
                  weight: 0,
                  dimensions: Dimensions(width: 0, height: 0, depth: 0),
                  warrantyInformation: '1 year warranty',
                  shippingInformation: 'Ships in 1 month',
                  availabilityStatus: 'In Stock',
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
                isDark,
              ),
            ),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    Product product,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.stock <= 5)
                Text(
                  'Only ${product.stock} left!',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                product.category.toUpperCase(),
                style: TextStyle(
                  color: Colors.deepPurple.shade300,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              if (product.brand != null) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  product.brand!,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Technical Specs'),
          _buildInfoGrid(product, isDark),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Logistics & Policy'),
          _buildLogisticsSection(product, isDark),
          const SizedBox(height: 32),
          _buildReviewsSection(context, product, isDark),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoGrid(Product product, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildInfoCard('SKU', product.sku, Iconsax.barcode, isDark),
        _buildInfoCard('Weight', '${product.weight}g', Iconsax.weight, isDark),
        _buildInfoCard(
          'Dimensions',
          '${product.dimensions.width}x${product.dimensions.height}x${product.dimensions.depth}',
          Iconsax.maximize_3,
          isDark,
        ),
        _buildInfoCard(
          'Min. Order',
          '${product.minimumOrderQuantity}',
          Iconsax.shopping_bag,
          isDark,
        ),
      ],
    );
  }

  Widget _buildLogisticsSection(Product product, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildLogisticsCard(
          'Availability',
          product.availabilityStatus,
          product.stock > 0 ? Iconsax.tick_circle : Iconsax.close_circle,
          product.stock > 0 ? Colors.green : Colors.red,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildLogisticsCard(
          'Warranty',
          product.warrantyInformation,
          Iconsax.shield_tick,
          Colors.blue,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildLogisticsCard(
          'Shipping',
          product.shippingInformation,
          Iconsax.truck_fast,
          Colors.orange,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildLogisticsCard(
          'Returns',
          product.returnPolicy,
          Iconsax.refresh_right_square,
          Colors.purple,
          isDark,
        ),
      ],
    );
  }

  Widget _buildLogisticsCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
    bool isDark,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    Product product,
    bool isDark,
  ) {
    if (product.reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(context, 'Customer Reviews'),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: BorderRadius.circular(12),
              color: Colors.amber,
              opacity: 0.1,
              child: Row(
                children: [
                   const Icon(Iconsax.star1, size: 16, color: Colors.amber),
                   const SizedBox(width: 4),
                   Text(
                     '${product.rating}',
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                   ),
                   const SizedBox(width: 4),
                   Text(
                     '(${product.reviews.length})',
                     style: const TextStyle(color: Colors.white38, fontSize: 11),
                   ),
                ],
              ),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.reviews.length,
          padding: EdgeInsets.only(top: 24),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = product.reviews[index];
            return GlassContainer(
              padding: const EdgeInsets.all(16),
              opacity: 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Iconsax.star1,
                            size: 14,
                            color: i < review.rating
                                ? Colors.amber
                                : Colors.white10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${review.date.day}/${review.date.month}/${review.date.year}',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      opacity: 0.05,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple.shade200),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    Product product,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, bottomPadding > 0 ? bottomPadding : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.4),
          ],
        ),
      ),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Price',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              Text(
                currencyFormat.format(product.price),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Product product;
  final bool isDark;
  final double statusBarHeight;

  _ProductHeaderDelegate({
    required this.product,
    required this.isDark,
    required this.statusBarHeight,
  });

  @override
  double get minExtent => statusBarHeight + 80;

  @override
  double get maxExtent => 400;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxShrink = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);
    final double currentExtent = math.max(minExtent, maxExtent - shrinkOffset);
    final double currentBlur = (progress > 0.6) ? 15.0 : 0.0;
    
    // Available height for content excluding status bar
    final double contentHeight = math.max(0.0, currentExtent - statusBarHeight);
    
    // Smoothly calculate image size based on available height and progress
    final double maxImageSizeAtStart = 250.0;
    final double minImageSizeAtEnd = 40.0;
    
    // Use available height as a constraint
    double imageSize = (maxImageSizeAtStart * (1 - progress)).clamp(minImageSizeAtEnd, maxImageSizeAtStart);
    
    // Ensure image doesn't exceed a reasonable portion of the header height when not collapsed
    if (progress <= 0.6) {
      final double maxHeightConstraint = contentHeight * 0.6;
      if (imageSize > maxHeightConstraint) {
        imageSize = maxHeightConstraint;
      }
    }

    final double titleFontSize = (24 * (1 - progress)).clamp(16, 24);

    return GlassContainer(
      borderRadius: BorderRadius.zero,
      blur: currentBlur,
      opacity: progress > 0.8 ? 0.2 : 0,
      showSheen: false,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: SizedBox(
              height: contentHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: math.max(0.0, 40 * (1 - progress))),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: (1 - progress) * 24 + (progress * 16)),
                        // Image container with fixed size to avoid jumping
                        Hero(
                          tag: 'product_${product.id}',
                          child: SizedBox(
                            height: imageSize,
                            width: progress > 0.6 ? 50 : imageSize,
                            child: product.thumbnail.isNotEmpty
                                ? Image.network(
                                    product.thumbnail,
                                    fit: BoxFit.contain,
                                  )
                                : Icon(Iconsax.image,
                                    size: imageSize / 2, color: Colors.white24),
                          ),
                        ),
                        if (progress > 0.6) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  ),
                  if (progress <= 0.6) ...[
                    const SizedBox(height: 8),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          product.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProductHeaderDelegate oldDelegate) {
    return oldDelegate.product != product || oldDelegate.isDark != isDark;
  }
}

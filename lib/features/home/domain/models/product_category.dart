/// Represents a product category with its display name and identifier.
class ProductCategory {
  /// Unique identifier/slug for the category.
  final String slug;
  /// Human-readable name of the category.
  final String name;
  /// URL pointing to the category's resource or image.
  final String url;

  ProductCategory({
    required this.slug,
    required this.name,
    required this.url,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      slug: json['slug'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'url': url,
    };
  }
}

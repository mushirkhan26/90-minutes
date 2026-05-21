class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final String categoryId;
  final List<String> images;
  final int stock;
  final bool isAvailable;
  final String unit; // e.g., "kg", "pcs", "500g"

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.categoryId,
    required this.images,
    required this.stock,
    this.isAvailable = true,
    required this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId']?.toString() ?? '',
      images: List<String>.from(json['images'] ?? []),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      unit: json['unit']?.toString() ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'categoryId': categoryId,
      'images': images,
      'stock': stock,
      'isAvailable': isAvailable,
      'unit': unit,
    };
  }
}

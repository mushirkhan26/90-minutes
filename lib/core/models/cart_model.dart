class CartModel {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;

  CartModel({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
  });

  double get total => subtotal + deliveryFee + tax;

  factory CartModel.empty() {
    return CartModel(
      items: [],
      subtotal: 0.0,
      deliveryFee: 0.0,
      tax: 0.0,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
    };
  }
}

class CartItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
    };
  }
}

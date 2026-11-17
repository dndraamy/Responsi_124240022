class CartItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  int quantity;
  final int stock;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.quantity,
    this.stock = 99,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 1,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock'].toString()) ?? 99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'quantity': quantity,
      'stock': stock,
    };
  }
}

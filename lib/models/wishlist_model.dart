class WishlistModel {
  String username;
  int productId;
  String title;
  double price;
  String thumbnail;
  int quantity;

  WishlistModel({
    required this.username,
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.quantity,
  });

  factory WishlistModel.fromMap(Map<dynamic, dynamic> m) {
    return WishlistModel(
      username: m['username'],
      productId: m['productId'],
      title: m['title'],
      price: (m['price'] as num).toDouble(),
      thumbnail:  m['thumbnail'],
      quantity: m['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'quantity': quantity,
    };
  }

}
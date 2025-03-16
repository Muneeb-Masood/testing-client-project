class Product {
  String name;
  String description;
  int price;
  String imageUrl;
  String productUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.productUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
    };
  }

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'],
      productUrl: json['productUrl'],
    );
  }
}

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.description,
    required super.imageUrl,
    super.favorite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['title'] ?? json['name'] ?? 'Produto sem nome',
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['thumbnail'] ?? json['image'] ?? json['imageUrl'],
      favorite: json['favorite'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'favorite': favorite,
    };
  }
}

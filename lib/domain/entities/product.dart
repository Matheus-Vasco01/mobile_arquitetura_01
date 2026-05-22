class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  bool favorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.imageUrl,
    this.favorite = false,
  });

  // Método para copiar com mudanças
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    bool? favorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      favorite: favorite ?? this.favorite,
    );
  }

  // Converter JSON para objeto Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? json['name'] ?? 'Produto sem nome',
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['thumbnail'] ?? json['image'] ?? json['imageUrl'],
      favorite: json['favorite'] ?? false,
    );
  }

  // Converter objeto Product para JSON
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

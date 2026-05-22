import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String category);
  Future<List<String>> getCategories();
  Future<Product> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductRemoteDataSourceImpl({required this.client});

  String _mapCategory(String category) {
    switch (category) {
      case 'electronics':
        return 'laptops';
      case 'jewelery':
        return 'womens-jewellery';
      case 'men\'s clothing':
        return 'mens-shirts';
      case 'women\'s clothing':
        return 'womens-dresses';
      default:
        return category;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    final response = await client.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> productsData = jsonData['products'];
      return productsData.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar produtos: ${response.statusCode}');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    final mappedCategory = _mapCategory(category);
    final response =
        await client.get(Uri.parse('$_baseUrl/products/category/$mappedCategory'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> productsData = jsonData['products'];
      return productsData.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar produtos por categoria: ${response.statusCode}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final response =
        await client.get(Uri.parse('$_baseUrl/products/categories'));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((item) {
          if (item is Map) {
            return item['slug'].toString();
          }
          return item.toString();
        }).toList();
      }
      return [];
    } else {
      throw Exception('Erro ao buscar categorias: ${response.statusCode}');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    final response = await client.get(Uri.parse('$_baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return ProductModel.fromJson(jsonData);
    } else {
      throw Exception('Erro ao buscar produto por ID: ${response.statusCode}');
    }
  }
}

import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String category);
  Future<List<String>> getCategories();
  Future<Product> getProductById(String id);
  Future<List<Product>> getFavoriteProducts();
  Future<void> saveFavoriteProducts(List<Product> favorites);
}

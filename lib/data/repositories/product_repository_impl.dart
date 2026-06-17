import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<List<Product>> _syncFavorites(List<Product> products) async {
    try {
      final favorites = await localDataSource.getFavoriteProducts();
      final favoriteIds = favorites.map((p) => p.id).toSet();
      for (var product in products) {
        product.favorite = favoriteIds.contains(product.id);
      }
    } catch (_) {
      // Ignora falhas e retorna a lista original
    }
    return products;
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
      return _syncFavorites(remoteProducts);
    } catch (e) {
      try {
        final cached = await localDataSource.getLastProducts();
        return _syncFavorites(cached);
      } catch (cacheError) {
        throw Exception(
            'Erro ao carregar dados: $e e cache vazio: $cacheError');
      }
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final remoteProducts =
          await remoteDataSource.getProductsByCategory(category);
      return _syncFavorites(remoteProducts);
    } catch (e) {
      // Se falhar a categoria, tentamos o cache geral
      try {
        final cached = await localDataSource.getLastProducts();
        final filtered = cached.where((p) => true).toList(); // simplificado
        return _syncFavorites(filtered);
      } catch (cacheError) {
        throw Exception(
            'Erro ao carregar dados por categoria e cache indisponível');
      }
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (e) {
      return [
        'electronics',
        'jewelery',
        'men\'s clothing',
        'women\'s clothing'
      ];
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    final product = await remoteDataSource.getProductById(id);
    final favorites = await localDataSource.getFavoriteProducts();
    product.favorite = favorites.any((p) => p.id == product.id);
    return product;
  }

  @override
  Future<List<Product>> getFavoriteProducts() async {
    return await localDataSource.getFavoriteProducts();
  }

  @override
  Future<void> saveFavoriteProducts(List<Product> favorites) async {
    await localDataSource.saveFavoriteProducts(favorites);
  }
}

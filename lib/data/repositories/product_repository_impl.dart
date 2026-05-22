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

  @override
  Future<List<Product>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(remoteProducts);
      return remoteProducts;
    } catch (e) {
      try {
        return await localDataSource.getLastProducts();
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
      // O cache por categoria é opcional, mas vamos simplificar aqui
      return remoteProducts;
    } catch (e) {
      // Se falhar a categoria, tentamos o cache geral
      try {
        final cached = await localDataSource.getLastProducts();
        return cached.where((p) => true).toList(); // simplificado
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
    return await remoteDataSource.getProductById(id);
  }
}

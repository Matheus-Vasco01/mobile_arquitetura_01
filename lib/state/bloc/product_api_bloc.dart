import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_api_event.dart';
import 'product_api_state.dart';

class ProductApiBloc extends Bloc<ProductApiEvent, ProductApiState> {
  final ProductRepository repository;
  List<Product> _products = [];

  ProductApiBloc({required this.repository}) : super(ProductApiInitialState()) {
    on<LoadProductsApiEvent>(_onLoadProducts);
    on<LoadProductsApiByCategory>(_onLoadProductsByCategory);
    on<ToggleFavoriteApiEvent>(_onToggleFavorite);
    on<AddProductApiEvent>(_onAddProduct);
    on<RemoveProductApiEvent>(_onRemoveProduct);
  }

  // Carregar produtos da API
  Future<void> _onLoadProducts(
    LoadProductsApiEvent event,
    Emitter<ProductApiState> emit,
  ) async {
    emit(ProductApiLoadingState());
    try {
      _products = await repository.getProducts();
      emit(ProductApiLoadedState(_products));
    } catch (e) {
      emit(ProductApiErrorState('Erro ao carregar produtos: $e'));
    }
  }

  // Carregar produtos por categoria
  Future<void> _onLoadProductsByCategory(
    LoadProductsApiByCategory event,
    Emitter<ProductApiState> emit,
  ) async {
    emit(ProductApiLoadingState());
    try {
      _products = await repository.getProductsByCategory(event.category);
      emit(ProductApiLoadedState(_products));
    } catch (e) {
      emit(ProductApiErrorState('Erro ao carregar produtos: $e'));
    }
  }

  // Alternar favorito
  Future<void> _onToggleFavorite(
    ToggleFavoriteApiEvent event,
    Emitter<ProductApiState> emit,
  ) async {
    final index = _products.indexWhere((p) => p.id == event.productId);
    if (index != -1) {
      final product = _products[index];
      product.favorite = !product.favorite;
      
      try {
        final favorites = await repository.getFavoriteProducts();
        if (product.favorite) {
          if (!favorites.any((p) => p.id == product.id)) {
            favorites.add(product);
          }
        } else {
          favorites.removeWhere((p) => p.id == product.id);
        }
        await repository.saveFavoriteProducts(favorites);
      } catch (_) {}
      
      emit(ProductApiLoadedState(List.from(_products)));
    } else {
      try {
        final favorites = await repository.getFavoriteProducts();
        final favIndex = favorites.indexWhere((p) => p.id == event.productId);
        if (favIndex != -1) {
          favorites.removeAt(favIndex);
        } else {
          final freshProduct = await repository.getProductById(event.productId);
          freshProduct.favorite = true;
          favorites.add(freshProduct);
        }
        await repository.saveFavoriteProducts(favorites);
      } catch (_) {}
    }
  }

  // Adicionar produto
  Future<void> _onAddProduct(
    AddProductApiEvent event,
    Emitter<ProductApiState> emit,
  ) async {
    _products.add(event.product);
    emit(ProductApiLoadedState(List.from(_products)));
  }

  // Remover produto
  Future<void> _onRemoveProduct(
    RemoveProductApiEvent event,
    Emitter<ProductApiState> emit,
  ) async {
    _products.removeWhere((p) => p.id == event.productId);
    emit(ProductApiLoadedState(List.from(_products)));
  }
}

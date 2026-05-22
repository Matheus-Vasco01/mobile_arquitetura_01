import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final List<Product> _products = [
    Product(id: '1', name: 'Notebook', price: 3500.0, imageUrl: ''),
    Product(id: '2', name: 'Mouse', price: 120.0, imageUrl: ''),
    Product(id: '3', name: 'Teclado', price: 250.0, imageUrl: ''),
    Product(id: '4', name: 'Monitor', price: 900.0, imageUrl: ''),
  ];

  ProductBloc() : super(ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<AddProductEvent>(_onAddProduct);
    on<RemoveProductEvent>(_onRemoveProduct);
  }

  // Carregar produtos
  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadingState());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProductLoadedState(_products));
    } catch (e) {
      emit(ProductErrorState('Erro ao carregar produtos'));
    }
  }

  // Alternar favorito
  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ProductState> emit,
  ) async {
    final index = _products.indexWhere((p) => p.id == event.productId);
    if (index != -1) {
      _products[index].favorite = !_products[index].favorite;
      emit(ProductLoadedState(List.from(_products)));
    }
  }

  // Adicionar produto
  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _products.add(event.product);
    emit(ProductLoadedState(List.from(_products)));
  }

  // Remover produto
  Future<void> _onRemoveProduct(
    RemoveProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _products.removeWhere((p) => p.id == event.productId);
    emit(ProductLoadedState(List.from(_products)));
  }
}

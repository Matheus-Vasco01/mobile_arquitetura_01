import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../core/session/session_manager.dart';
import '../../domain/entities/product.dart';
import '../../state/bloc/product_api_bloc.dart';
import '../../state/bloc/product_api_event.dart';
import '../../state/bloc/product_api_state.dart';
import '../../state/provider/product_api_provider.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = provider_pkg.Provider.of<ProductApiProvider>(context, listen: false).repository;
      final favorites = await repository.getFavoriteProducts();
      if (mounted) {
        setState(() {
          _favoriteProducts = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erro ao carregar favoritos.";
          _isLoading = false;
        });
      }
    }
  }

  void _onToggleFavorite(Product product) {
    // 1. Dispatch the toggle event to BLoC so the rest of the app knows
    context.read<ProductApiBloc>().add(ToggleFavoriteApiEvent(product.id));

    // 2. Remove the product from the local favorites list immediately for reactive UI
    setState(() {
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    });

    // 3. Show a snackbar giving feedback with option to undo
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${product.name} removido dos favoritos",
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        action: SnackBarAction(
          label: "Desfazer",
          textColor: Colors.amber,
          onPressed: () {
            // Dispatch to BLoC to add it back
            context.read<ProductApiBloc>().add(ToggleFavoriteApiEvent(product.id));
            // Add back to local favorites list and trigger state update
            setState(() {
              product.favorite = true;
              _favoriteProducts.add(product);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = provider_pkg.Provider.of<SessionManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Velour",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (session.isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(session.currentUser!.image),
                radius: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF6B1123)),
              tooltip: "Sair",
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                session.logout();
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocListener<ProductApiBloc, ProductApiState>(
        listener: (context, state) {
          // Se a lista de produtos no catálogo mudar e redefinir o favorito de algum item, 
          // ou se houver alteração geral, recarregamos para manter sincronizado.
          if (state is ProductApiLoadedState) {
            _loadFavorites();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Meus Favoritos",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sua lista personalizada de itens desejados.",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: GoogleFonts.montserrat(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text("Tentar novamente"),
            ),
          ],
        ),
      );
    }

    if (_favoriteProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1123).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  size: 64,
                  color: Color(0xFF6B1123),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Sua lista está vazia",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Navegue pelo catálogo e favorite seus itens preferidos para vê-los aqui.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Voltar para a Loja"),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              onFavoriteChanged: (isFavorite) {
                context
                    .read<ProductApiBloc>()
                    .add(ToggleFavoriteApiEvent(product.id));
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF9F9F9),
                      padding: const EdgeInsets.all(16),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          size: 20,
                          color: Color(0xFF6B1123),
                        ),
                        onPressed: () => _onToggleFavorite(product),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PRODUTO",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B1123),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../core/session/session_manager.dart';
import '../../domain/entities/product.dart';
import '../../state/bloc/product_api_bloc.dart';
import '../../state/bloc/product_api_event.dart';
import '../../state/bloc/product_api_state.dart';
import 'product_detail_page.dart';

class BlocApiProductPage extends StatefulWidget {
  final String? initialCategory;
  const BlocApiProductPage({super.key, this.initialCategory});

  @override
  State<BlocApiProductPage> createState() => _BlocApiProductPageState();
}

class _BlocApiProductPageState extends State<BlocApiProductPage> {
  final List<String> categories = [
    'Todos',
    'electronics',
    'jewelery',
    'men\'s clothing',
    'women\'s clothing'
  ];
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'Todos';
    _loadProducts();
  }

  void _loadProducts() {
    if (selectedCategory == 'Todos') {
      context.read<ProductApiBloc>().add(LoadProductsApiEvent());
    } else {
      context
          .read<ProductApiBloc>()
          .add(LoadProductsApiByCategory(selectedCategory));
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'electronics':
        return 'Eletrônicos';
      case 'jewelery':
        return 'Joias';
      case 'men\'s clothing':
        return 'Masculino';
      case 'women\'s clothing':
        return 'Feminino';
      default:
        return category;
    }
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Catálogo de Produtos",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Navegue por nossa coleção exclusiva de produtos selecionados.",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                      _loadProducts();
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF6B1123),
                    labelStyle: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : const Color(0xFF6B1123),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color(0xFF6B1123).withValues(alpha: 0.2),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<ProductApiBloc, ProductApiState>(
              builder: (context, state) {
                if (state is ProductApiLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductApiLoadedState) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return _buildProductCard(context, product);
                    },
                  );
                } else if (state is ProductApiErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erro: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text("Tentar novamente"),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
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
                        icon: Icon(
                          product.favorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: product.favorite ? const Color(0xFF6B1123) : Colors.grey,
                        ),
                        onPressed: () {
                          context
                              .read<ProductApiBloc>()
                              .add(ToggleFavoriteApiEvent(product.id));
                        },
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
                    _getCategoryLabel(selectedCategory == 'Todos' ? 'Produto' : selectedCategory).toUpperCase(),
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

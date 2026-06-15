import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../state/provider/product_api_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final ValueChanged<bool>? onFavoriteChanged;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onFavoriteChanged,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;
  bool _isLoadingDetails = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    // Agendar o carregamento dos detalhes após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductDetails();
    });
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoadingDetails = true;
      _error = null;
    });

    try {
      final repository = Provider.of<ProductApiProvider>(context, listen: false).repository;
      final freshProduct = await repository.getProductById(_currentProduct.id);
      if (mounted) {
        setState(() {
          final wasFavorite = _currentProduct.favorite;
          _currentProduct = freshProduct.copyWith(favorite: wasFavorite);
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erro ao carregar dados em tempo real da API.";
          _isLoadingDetails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Velour",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoadingDetails)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B1123)),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 400,
              color: const Color(0xFFF9F9F9),
              padding: const EdgeInsets.all(32),
              child: _currentProduct.imageUrl != null
                  ? Image.network(
                      _currentProduct.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 100),
                    )
                  : const Icon(Icons.image, size: 100),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchProductDetails,
                      child: Text(
                        "TENTAR NOVAMENTE",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B1123),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentProduct.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _currentProduct.favorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: const Color(0xFF6B1123),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentProduct.favorite = !_currentProduct.favorite;
                          });
                          widget.onFavoriteChanged?.call(_currentProduct.favorite);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'R\$ ${_currentProduct.price.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B1123),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'DESCRIÇÃO',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentProduct.description ?? 'Sem descrição disponível.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("ADICIONAR À SACOLA"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

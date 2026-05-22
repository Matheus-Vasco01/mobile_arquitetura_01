import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/provider/product_api_provider.dart';
import 'product_detail_page.dart';

class ProviderApiProductPage extends StatefulWidget {
  const ProviderApiProductPage({super.key});

  @override
  State<ProviderApiProductPage> createState() => _ProviderApiProductPageState();
}

class _ProviderApiProductPageState extends State<ProviderApiProductPage> {
  List<String> categories = [];
  String selectedCategory = 'electronics';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductApiProvider>().loadProductsByCategory('electronics');
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      categories = [
        'electronics',
        'jewelery',
        'men\'s clothing',
        'women\'s clothing'
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✰ Provider"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                  context
                      .read<ProductApiProvider>()
                      .loadProductsByCategory(value);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<ProductApiProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erro: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadProductsByCategory(selectedCategory);
                          },
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      leading: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image),
                      title: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(
                          product.favorite ? Icons.star : Icons.star_border,
                          color: product.favorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(product.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

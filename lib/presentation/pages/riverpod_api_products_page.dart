import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/riverpod/product_riverpod_api.dart';
import 'product_detail_page.dart';

class RiverpodApiProductPage extends ConsumerStatefulWidget {
  const RiverpodApiProductPage({super.key});

  @override
  ConsumerState<RiverpodApiProductPage> createState() =>
      _RiverpodApiProductPageState();
}

class _RiverpodApiProductPageState
    extends ConsumerState<RiverpodApiProductPage> {
  List<String> categories = [];
  String selectedCategory = 'electronics';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productApiProvider.notifier)
          .loadProductsByCategory('electronics');
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
    final products = ref.watch(productApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("✰ Riverpod"),
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
                  ref
                      .read(productApiProvider.notifier)
                      .loadProductsByCategory(value);
                }
              },
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: product,
                                onFavoriteChanged: (isFavorite) {
                                  ref
                                      .read(productApiProvider.notifier)
                                      .toggleFavorite(product.id);
                                },
                              ),
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
                        subtitle:
                            Text('R\$ ${product.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(
                            product.favorite ? Icons.star : Icons.star_border,
                            color:
                                product.favorite ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            ref
                                .read(productApiProvider.notifier)
                                .toggleFavorite(product.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

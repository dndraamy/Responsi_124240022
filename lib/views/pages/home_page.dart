import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ProductModel> products = [];
  List<String> categories = ['Semua'];
  String selectedCategory = 'Semua';
  bool isLoading = true;
  String username = '';

  static const Color shopeeOrange = Color(0xFFEE4D2D);

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadCategories();
    fetchProducts();
  }

  Future<void> _loadUsername() async {
    final name = await LocalStorageService.getName();
    if (!mounted) return;
    setState(() => username = name);
  }

  Future<void> _loadCategories() async {
    try {
      final list = await ApiService.getCategories();
      if (!mounted) return;
      setState(() => categories = ['Semua', ...list]);
    } catch (_) {}
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      List<ProductModel> result;
      if (selectedCategory == 'Semua') {
        result = await ApiService.getProducts();
      } else {
        result = await ApiService.getProductsByCategory(selectedCategory);
      }
      if (!mounted) return;
      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat produk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleWishlist(ProductModel product) async {
    final isFav = LocalStorageService.isWishlist(product.id);
    if (isFav) {
      await LocalStorageService.removeWishlist(product.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} dihapus dari wishlist'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await LocalStorageService.addWishlist(product);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} ditambahkan ke wishlist'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username.isNotEmpty ? 'Hai, $username' : 'ShoppingHub',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: shopeeOrange,
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
              setState(() {});
            },
          ),
          // Badge jumlah item di keranjang
          ValueListenableBuilder(
            valueListenable: LocalStorageService.getCartBox().listenable(),
            builder: (context, box, child) {
              final cartCount = box.length;
              return Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: Colors.white,
                textColor: shopeeOrange,
                child: IconButton(
                  tooltip: 'Keranjang',
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    setState(() {});
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter kategori horizontal
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: shopeeOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    if (selected && selectedCategory != cat) {
                      setState(() => selectedCategory = cat);
                      fetchProducts();
                    }
                  },
                );
              },
            ),
          ),

          // Grid produk
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: shopeeOrange),
                  )
                : products.isEmpty
                ? const Center(child: Text('Tidak ada produk tersedia.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isFav = LocalStorageService.isWishlist(product.id);

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(productId: product.id),
                            ),
                          );
                          setState(() {});
                        },
                        child: Card(
                          elevation: 1.5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 135,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.network(
                                      product.thumbnail,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  // Badge diskon
                                  if (product.discountPercentage > 0)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade700,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Tombol wishlist
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFav ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () => _toggleWishlist(product),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: shopeeOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

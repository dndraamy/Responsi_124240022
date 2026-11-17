import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import 'cart_page.dart';

class DetailPage extends StatefulWidget {
  final int productId;
  const DetailPage({super.key, required this.productId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ProductModel? product;
  bool isLoading = true;
  bool isWishlist = false;
  int quantity = 1;

  static const Color shopeeOrange = Color(0xFFEE4D2D);

  @override
  void initState() {
    super.initState();
    _checkWishlist();
    fetchSingleProduct();
  }

  void _checkWishlist() {
    setState(() {
      isWishlist = LocalStorageService.isWishlist(widget.productId);
    });
  }

  Future<void> fetchSingleProduct() async {
    try {
      final data = await ApiService.getSingleProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        product = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail produk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleWishlist() async {
    if (product == null) return;

    if (isWishlist) {
      await LocalStorageService.removeWishlist(product!.id);
      if (!mounted) return;
      setState(() => isWishlist = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product!.title} dihapus dari wishlist'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await LocalStorageService.addWishlist(product!);
      if (!mounted) return;
      setState(() => isWishlist = true);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product!.title} ditambahkan ke wishlist'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addToCart() {
    if (product == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$quantity x ${product!.title} ditambahkan ke keranjang!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
        ),
      ),
    );

    LocalStorageService.addToCart(product!, quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: shopeeOrange,
        actions: [
          IconButton(
            tooltip: isWishlist ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
            icon: Icon(
              isWishlist ? Icons.favorite : Icons.favorite_border,
              color: isWishlist ? Colors.redAccent : Colors.white,
            ),
            onPressed: product != null ? _toggleWishlist : null,
          ),
          // Badge jumlah item di keranjang
          ValueListenableBuilder(
            valueListenable: LocalStorageService.getCartBox().listenable(),
            builder: (context, box, child) {
              final count = box.length;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                backgroundColor: Colors.white,
                textColor: shopeeOrange,
                child: IconButton(
                  tooltip: 'Keranjang',
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: shopeeOrange))
          : product == null
          ? const Center(child: Text('Data produk tidak ditemukan.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar produk
                  Center(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        product!.thumbnail.isNotEmpty
                            ? product!.thumbnail
                            : (product!.images.isNotEmpty
                                  ? product!.images[0]
                                  : ''),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Harga & badge diskon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product!.price}',
                        style: const TextStyle(
                          fontSize: 26,
                          color: shopeeOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (product!.discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product!.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nama produk
                  Text(
                    product!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Kategori & brand
                  Row(
                    children: [
                      Text(
                        'Kategori: ${product!.category}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      if (product!.brand != null &&
                          product!.brand!.trim().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          '| Brand: ${product!.brand}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating & stok
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${product!.rating} / 5.0',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: shopeeOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stok: ${product!.stock}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Pilihan jumlah
                  Row(
                    children: [
                      const Text(
                        'Kuantitas:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: quantity < product!.stock
                            ? () => setState(() => quantity++)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Deskripsi produk
                  const Text(
                    'Deskripsi Produk:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product!.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      // Bottom bar: tombol wishlist & tambah ke keranjang
      bottomNavigationBar: product == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      tooltip: isWishlist
                          ? 'Hapus dari Wishlist'
                          : 'Simpan ke Wishlist',
                      icon: Icon(
                        isWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isWishlist ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      onPressed: _toggleWishlist,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: product!.stock > 0 ? _addToCart : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: const Text(
                            'Tambah ke Keranjang',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: shopeeOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

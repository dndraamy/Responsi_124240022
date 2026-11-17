import 'package:flutter/material.dart';


import '../../models/product_model.dart';
import '../../models/wishlist_model.dart';
// import '../../models/cart_item_model.dart';
// import '../../services/session_service.dart';
// import '../../services/cart_service.dart';
import 'wishlist_page.dart';
import '../../services/local_storage_service.dart';

class DetailPage extends StatefulWidget {
  final ProductModel product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await LocalStorageService.isFavorite(widget.product.id);
    if (!mounted) return;
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final p = widget.product;
    if (_isFavorite) {
      await LocalStorageService.removeFavorite(p.id);
      if (!mounted) return;
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p.title} dihapus dari favorit'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await LocalStorageService.addFavorite(p as WishlistModel);
      if (!mounted) return;
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p.title} ditambahkan ke favorit'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

// class _DetailPageState extends State<DetailPage> {
//   int _qty = 1;

//   Future<void> _addToCart() async {
//     final p = widget.product;
//     final username = await SessionService.getUsername();

  //   await CartService.addToCart(
  //     CartItemModel(
  //       username: username,
  //       productId: p.id,
  //       title: p.title,
  //       price: p.price,
  //       thumbnail: p.thumbnail,
  //       quantity: _qty,
  //     ),
  //   );

  //   await NotificationService().showInstantNotification(
  //   title: 'Ditambahkan ke keranjang 🛒',
  //   body: '${p.title} x$_qty',
  // );

  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan')));
  // }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                p.images.isNotEmpty ? p.images.first : p.thumbnail,
                height: 250,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Kategori: ${p.category}'),
            const SizedBox(height: 8),
            Text(
              '\$${p.price}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${p.rating}  |  Stok: ${p.stock}'),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(p.description),
            const SizedBox(height: 24),
            // Row(
            //   children: [
            //     IconButton(
            //       icon: const Icon(Icons.remove_circle_outline),
            //       onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
            //     ),
            //     Text('$_qty', style: const TextStyle(fontSize: 18)),
            //     IconButton(
            //       icon: const Icon(Icons.add_circle_outline),
            //       onPressed: _qty < p.stock
            //           ? () => setState(() => _qty++)
            //           : null,
            //     ),
            //     const Spacer(),
            //     ElevatedButton.icon(
            //       onPressed: p.stock > 0 ? _addToCart : null,
            //       icon: const Icon(Icons.shopping_cart),
            //       label: const Text('Add to Cart'),
            //     ),
            //   ],
            // ),
            // Tombol Favorite
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : Colors.orange,
              ),
              label: Text(
                _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isFavorite ? Colors.white : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? Colors.orange : Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

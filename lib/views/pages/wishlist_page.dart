import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/local_storage_service.dart';
import 'detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  static const Color shopeeOrange = Color(0xFFEE4D2D);

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Saya'),
        backgroundColor: shopeeOrange,
      ),
      body: ValueListenableBuilder(
        valueListenable: LocalStorageService.getWishlistBox().listenable(),
        builder: (_, box, _) {
          final items = LocalStorageService.getWishlist();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Wishlist Masih Kosong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ayo simpan produk favoritmu di sini!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemBuilder: (ctx, index) {
              final product = items[index];

              return Card(
                elevation: 1,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image, size: 30),
                    ),
                  ),
                  title: Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      color: shopeeOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      final title = product.title;
                      final id = product.id;

                      LocalStorageService.removeWishlist(id);

                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('$title dihapus dari wishlist'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(productId: product.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

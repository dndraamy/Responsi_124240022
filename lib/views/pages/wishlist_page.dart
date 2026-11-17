import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/local_storage_service.dart';
import '../../theme/app_theme.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<ProductModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favs = await LocalStorageService.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favs.cast<ProductModel>();
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(ProductModel product, int index) async {
    final removed = product;
    setState(() {
      _favorites.removeAt(index);
    });

    await LocalStorageService.removeFavorite(removed.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removed.title} berhasil dihapus dari favorit'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Wishlist Produk'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 44,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Daftar favorit masih kosong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tekan ikon hati pada karakter untuk menambahkannya ke daftar favorit',
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final character = _favorites[index];

                      return Dismissible(
                        key: Key('fav_${character.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete, color: Colors.white),
                            ],
                          ),
                        ),
                        onDismissed: (_) {
                          _removeFavorite(character, index);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: character.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      character.images.first,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 40),
                                    ),
                                  )
                                : const Icon(Icons.person, size: 40),
                            title: Text(
                              character.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            // subtitle: Text(
                            //   character.jutsu.isNotEmpty
                            //       ? character.jutsu.first
                            //       : 'Tidak ada jutsu tercatat',
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(color: AppTheme.textSecondary),
                            // ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(product: character),
                                ),
                              );
                              _loadFavorites();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

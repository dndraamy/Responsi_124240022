import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import 'wishlist_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ProductModel>> _future;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _future = ApiService.getProducts();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await SessionService.getUsername();
    if (!mounted) return;
    setState(() => _username = name);
  }

  void _reload() {
    setState(() {
      _future = ApiService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $_username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat produk'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: Image.network(p.thumbnail, width: 50, height: 50),
                  title: Text(p.title),
                  subtitle: Text('${p.category} | \$${p.price}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(product: p,),
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
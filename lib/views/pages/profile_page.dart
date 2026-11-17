import 'package:flutter/material.dart';

import '../../services/local_storage_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String? nama;
  const ProfilePage({super.key, this.nama});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nama = '';

  static const Color shopeeOrange = Color(0xFFEE4D2D);

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    if (widget.nama != null && widget.nama!.isNotEmpty) {
      setState(() => _nama = widget.nama!);
    } else {
      final n = await LocalStorageService.getName();
      if (!mounted) return;
      setState(() => _nama = n);
    }
  }

  void _logout() async {
    await LocalStorageService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: shopeeOrange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: shopeeOrange),
              const SizedBox(height: 16),
              Text(
                _nama.isNotEmpty ? _nama : 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ShoppingHub Member',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: shopeeOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 45),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

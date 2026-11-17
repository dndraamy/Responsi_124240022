import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_model.dart';
import 'theme/app_theme.dart';
import 'views/bottom_navigation.dart';
import 'views/pages/login_page.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Daftarkan TypeAdapter dan buka box untuk UserModel
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users_box');
  await Hive.openBox('cart');

  final isLogin = await SessionService.isLogin();

  runApp(MyApp(isLogin: isLogin));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  const MyApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShoppingHub',
      theme: AppTheme.lightTheme,
      home: isLogin ? const BottomNavigation() : const LoginPage(),
    );
  }
}
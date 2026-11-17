import 'local_storage_service.dart';

class SessionService {
  static Future<void> saveSession(String username) async {
    // Session disimpan lewat LocalStorageService
  }

  static Future<String> getUsername() async {
    return LocalStorageService.getUsername();
  }

  static Future<bool> isLogin() async {
    return LocalStorageService.isLoggedIn();
  }

  static Future<void> clearSession() async {
    return LocalStorageService.logout();
  }
}
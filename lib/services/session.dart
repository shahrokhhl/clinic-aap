import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// وضعیت ورود کاربر + تنظیمات اتصال به «سرور محلی کلینیک».
/// در فاز ۱ (همین اسکلت)، لاگین به‌صورت نمایشی/محلی است. در فاز ۲ که
/// بک‌اند FastAPI آماده شد، login() واقعاً به سرور کلینیک وصل می‌شود و
/// یک JWT token برمی‌گرداند.
class Session extends ChangeNotifier {
  String? userName;
  String role = 'admin'; // 'admin' | 'staff'
  List<String> permissions = [];
  String serverUrl = ''; // آدرس سرور محلی کلینیک، مثلاً http://192.168.1.10:8000

  bool get isLoggedIn => userName != null;
  bool get isAdmin => role == 'admin';

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    serverUrl = prefs.getString('server_url') ?? '';
    final savedUser = prefs.getString('user_name');
    if (savedUser != null) {
      userName = savedUser;
      role = prefs.getString('role') ?? 'admin';
    }
    notifyListeners();
  }

  Future<void> saveServerUrl(String url) async {
    serverUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    notifyListeners();
  }

  Future<void> login({required String user, required String role}) async {
    userName = user;
    this.role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user);
    await prefs.setString('role', role);
    notifyListeners();
  }

  Future<void> logout() async {
    userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    notifyListeners();
  }
}

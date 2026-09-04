import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// لایه‌ی ارتباط با «سرور محلی کلینیک» (فاز ۲ نقشه‌راه: FastAPI + WebSocket
/// که روی سیستم خودِ کلینیک اجرا می‌شود، نه روی سرور نوراژ).
///
/// امروز این کلاس فقط اسکلت و قرارداد (interface) نهایی است؛ چون بک‌اند
/// هنوز نوشته نشده، UI برنامه از MockDataService استفاده می‌کند (در همین
/// پوشه) تا بتوانید بدون بک‌اند هم برنامه را ببینید و تست کنید. وقتی
/// بک‌اند فاز ۲ آماده شد، کافی‌ست در main.dart، Provider ای که
/// MockDataService می‌دهد را با ApiService عوض کنید — چون هر دو همین
/// اینترفیس (متدهای fetchRows/addRow/updateRow/deleteRow/streamUpdates)
/// را پیاده می‌کنند.
class ApiService {
  final String baseUrl; // مثلاً http://192.168.1.10:8000  یا آدرس Tailscale
  final String? authToken;

  ApiService({required this.baseUrl, this.authToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<List<Map<String, dynamic>>> fetchRows(String moduleKey) async {
    final res = await http.get(Uri.parse('$baseUrl/api/$moduleKey'), headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('خطا در دریافت اطلاعات ($moduleKey): ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addRow(String moduleKey, Map<String, dynamic> row) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/$moduleKey'),
      headers: _headers,
      body: jsonEncode(row),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('خطا در ثبت ($moduleKey): ${res.statusCode}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<void> updateRow(String moduleKey, String id, Map<String, dynamic> row) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/$moduleKey/$id'),
      headers: _headers,
      body: jsonEncode(row),
    );
    if (res.statusCode != 200) {
      throw Exception('خطا در ویرایش ($moduleKey/$id): ${res.statusCode}');
    }
  }

  Future<void> deleteRow(String moduleKey, String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/$moduleKey/$id'), headers: _headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('خطا در حذف ($moduleKey/$id): ${res.statusCode}');
    }
  }

  /// اتصال WebSocket برای دریافت آنیِ تغییراتی که سیستم‌های دیگر همان
  /// کلینیک ثبت می‌کنند (ثبت خدمت/ویزیت از یک سیستم دیگر، بلافاصله اینجا
  /// هم پوش می‌شود، بدون نیاز به رفرش دستی).
  WebSocketChannel connectRealtime() {
    final wsUrl = baseUrl.replaceFirst('http', 'ws') + '/ws';
    return WebSocketChannel.connect(Uri.parse(wsUrl));
  }
}

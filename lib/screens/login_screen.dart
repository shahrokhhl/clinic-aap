import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _serverCtrl = TextEditingController(text: 'http://192.168.1.10:8000');
  bool _showServerField = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppColors.blue.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Icon(FontAwesomeIcons.notesMedical, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text('ورود به سامانه کلینیک',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('هر اپراتور با نام‌کاربری و رمزِ عبورِ خودش وارد می‌شود',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userCtrl,
                          decoration: const InputDecoration(
                            labelText: 'نام کاربری',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'رمز عبور',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          onSubmitted: (_) => _tryLogin(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12.5)),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _showServerField = !_showServerField),
                            icon: const Icon(FontAwesomeIcons.server, size: 13),
                            label: const Text('تنظیم آدرس سرور کلینیک', style: TextStyle(fontSize: 12.5)),
                          ),
                        ),
                        if (_showServerField)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: _serverCtrl,
                              decoration: const InputDecoration(
                                labelText: 'آدرس سرور محلی (IP یا آدرس Tailscale)',
                                prefixIcon: Icon(FontAwesomeIcons.networkWired, size: 15),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _tryLogin,
                            child: const Text('ورود'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// احرازِ هویت: نام‌کاربری/رمز باید با یکی از رکوردهای ماژولِ «کاربران و
  /// دسترسی‌ها» (لیستِ users در MockDataService) تطبیق داشته باشد؛ اگر
  /// حساب غیرفعال باشد هم اجازه‌ی ورود داده نمی‌شود. نکته: در فاز ۲ (بک‌اندِ
  /// واقعیِ FastAPI)، این چک باید سمتِ سرور و با رمزِ هش‌شده (نه متنِ ساده)
  /// انجام شود — این پیاده‌سازیِ محلی فقط برای نمایش و تستِ رابط کاربری است.
  void _tryLogin() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final users = context.read<MockDataService>().rows('users');
    final matches = users.where((u) => u['username'] == username && u['password'] == password).toList();

    if (matches.isEmpty) {
      setState(() => _error = 'نام کاربری یا رمز عبور اشتباه است');
      return;
    }
    final user = matches.first;
    if (user['active'] != 'فعال') {
      setState(() => _error = 'این حساب کاربری غیرفعال شده است');
      return;
    }

    final role = user['role'] == 'مدیر سیستم' ? 'admin' : 'staff';
    final session = context.read<Session>();
    await session.saveServerUrl(_serverCtrl.text.trim());
    await session.login(user: (user['fullName'] as String?) ?? username, role: role);
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ShellScreen()));
    }
  }
}

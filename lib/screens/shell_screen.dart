import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../config/modules_config.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import 'dashboard_screen.dart';
import 'dental_screen.dart';
import 'module_screen.dart';
import 'payroll_screen.dart';

/// چارچوب اصلی برنامه پس از ورود — واکنش‌گرا (responsive):
/// روی صفحه‌ی بزرگ (دسکتاپ)، سایدبار همیشه کنارِ محتوا نمایش داده می‌شود؛
/// روی موبایل، سایدبار به Drawer کشویی تبدیل می‌شود — یعنی همین یک کد،
/// هم برای exe ویندوز هم برای اپ اندروید/iOS کار می‌کند.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  String selected = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final session = context.watch<Session>();

    final content = selected == 'dashboard'
        ? const DashboardScreen()
        : selected == 'payroll'
            ? const PayrollScreen()
            : selected == 'dental'
                ? const DentalScreen()
                : ModuleScreen(moduleKey: selected);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            AppSidebar(selectedKey: selected, onSelect: (k) => setState(() => selected = k)),
            Expanded(
              child: Column(
                children: [
                  _TopBar(userName: session.userName ?? '', onLogout: session.logout),
                  Expanded(child: content),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(selected)),
      ),
      drawer: Drawer(
        child: AppSidebar(selectedKey: selected, onSelect: (k) {
          setState(() => selected = k);
          Navigator.pop(context);
        }),
      ),
      body: content,
    );
  }

  String _titleFor(String key) {
    if (key == 'dashboard') return 'داشبورد مدیریتی';
    if (key == 'payroll') return 'فیش تسویه حساب';
    if (key == 'dental') return 'دندانپزشکی';
    return modulesConfig[key]?.title ?? 'کلینیک نوراژ';
  }
}

class _TopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;
  const _TopBar({required this.userName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.green),
                SizedBox(width: 6),
                Text('متصل به سرور محلی', style: TextStyle(fontSize: 11.5, color: AppColors.green)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.blue,
            child: Text(userName.isNotEmpty ? userName[0] : '؟',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 6),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 15, color: AppColors.textSecondary),
            tooltip: 'خروج',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

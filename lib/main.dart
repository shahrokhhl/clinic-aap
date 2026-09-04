import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mock_data_service.dart';
import 'services/session.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Session()..loadSaved()),
        // نکته‌ی مهم برای فاز ۲: وقتی بک‌اند FastAPI آماده شد، این خط را با
        // Provider<ApiService>(create: (_) => ApiService(baseUrl: ...)) عوض کنید
        // و در ماژول‌ها به‌جای context.read<MockDataService>() از
        // context.read<ApiService>() استفاده کنید — بقیه‌ی UI دست‌نخورده می‌ماند.
        ChangeNotifierProvider(create: (_) => MockDataService()),
      ],
      child: MaterialApp(
        title: 'نرم‌افزار حسابداری کلینیک',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    return session.isLoggedIn ? const ShellScreen() : const LoginScreen();
  }
}

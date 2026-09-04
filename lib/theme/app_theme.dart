import 'package:flutter/material.dart';

/// پالت رنگیِ برنامه — ادامه‌ی همان رنگ‌بندیِ نسخه‌ی پایتونی (بنفش/ایندیگو
/// مدرن به‌جای آبیِ تختِ اداری قبلی)، فقط با عمق و گرادیانِ بیشتر که در
/// Tkinter اصلاً ممکن نبود.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFF4F5FB);
  static const card = Color(0xFFFFFFFF);
  static const sidebar = Color(0xFF1E1B3A);
  static const sidebarActive = Color(0xFF4F46E5);

  static const blue = Color(0xFF4F46E5);
  static const blueLight = Color(0xFF6366F1);
  static const purple = Color(0xFF8B5CF6);

  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFDCFCE7);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFEE2E2);
  static const amber = Color(0xFFD97706);
  static const amberLight = Color(0xFFFEF3C7);

  static const textPrimary = Color(0xFF1E1B2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  static const gradientStart = Color(0xFF4F46E5);
  static const gradientEnd = Color(0xFF7C3AED);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'Vazirmatn'),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}

/// گرادیان‌های آماده برای کارت‌های آماریِ داشبورد
class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const success = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
  );

  static const warning = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  static const danger = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );
}

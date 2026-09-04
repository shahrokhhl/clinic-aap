/// انواع فیلدهای فرم — دقیقاً معادل type هایی که در modules_config.py پایتون
/// استفاده شده بود (date, money, percent, select, text, patient_picker و...)
enum FieldType {
  text,
  date,
  money,
  percent,
  select,
  patientPicker,
  comboFree, // درمانگر/دکتر - قابل تایپ آزاد هم هست
  comboSettings, // آیتم/خدمت - از لیست تنظیمات پر می‌شود
  boolean,
  password, // مثل text ولی نمایش نقطه‌چین (obscureText) دارد
}

class ModuleField {
  final String key;
  final String label;
  final FieldType type;
  final List<String>? options;
  final String? hint;
  final bool required;

  const ModuleField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.hint,
    this.required = false,
  });
}

class ModuleColumn {
  final String key;
  final String label;

  /// اگر مقدار ستون باید از خروجی محاسبه (compute) گرفته شود، این تابع
  /// مقدار نهایی را از روی ردیف (row) برمی‌گرداند. اگر null باشد، مستقیم
  /// از row[key] خوانده می‌شود.
  final String Function(Map<String, dynamic> row)? calc;

  const ModuleColumn({required this.key, required this.label, this.calc});
}

class SummaryItem {
  final String label;
  final String value;
  const SummaryItem({required this.label, required this.value});
}

class ModuleDef {
  final String key;
  final String title;
  final String addLabel;
  final bool noMonthFilter;
  final List<ModuleField> fields;
  final List<ModuleColumn> columns;

  /// محاسبه‌ی کارت‌های آماریِ بالای صفحه از روی همه‌ی ردیف‌های فیلترشده
  final List<SummaryItem> Function(List<Map<String, dynamic>> rows)? summary;

  const ModuleDef({
    required this.key,
    required this.title,
    required this.addLabel,
    this.noMonthFilter = false,
    required this.fields,
    required this.columns,
    this.summary,
  });
}

class NavItem {
  final String key;
  final String label;
  final String icon; // نام آیکون (font_awesome) یا ایموجی به‌عنوان جایگزین
  const NavItem(this.key, this.label, this.icon);
}

class NavGroup {
  final String title;
  final List<NavItem> items;
  const NavGroup(this.title, this.items);
}

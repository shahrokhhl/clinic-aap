import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

final _moneyFormatter = NumberFormat('#,###');

double toNum(dynamic v) {
  if (v == null || v == '') return 0.0;
  if (v is num) return v.toDouble();
  final cleaned = v.toString().replaceAll(',', '').trim();
  return double.tryParse(cleaned) ?? 0.0;
}

/// معادل fmt_money پایتون: عدد را با جداکننده‌ی هزارگان نشان می‌دهد
String fmtMoney(dynamic v) {
  final n = toNum(v).round();
  return _moneyFormatter.format(n);
}

/// معادل fmt_percent پایتون: عدد اعشاری (۰ تا ۱) را به درصد فارسی تبدیل می‌کند
String fmtPercent(dynamic v) {
  final p = toNum(v) * 100;
  final rounded = (p * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(1);
  return '$text٪';
}

/// مهرِ زمانیِ شمسی برای اطلاعاتِ حسابرسی (ثبت/ویرایش) — مثلاً «۱۴۰۳/۰۶/۱۵ ۱۴:۳۲»
String nowJalaliStamp() {
  final j = Jalali.now();
  final now = DateTime.now();
  final hh = now.hour.toString().padLeft(2, '0');
  final mm = now.minute.toString().padLeft(2, '0');
  final y = j.year.toString().padLeft(4, '0');
  final m = j.month.toString().padLeft(2, '0');
  final d = j.day.toString().padLeft(2, '0');
  return '$y/$m/$d $hh:$mm';
}

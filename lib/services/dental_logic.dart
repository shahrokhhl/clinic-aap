import 'package:shamsi_date/shamsi_date.dart';
import '../config/formatters.dart';

/// وضعیتِ محاسبه‌شده‌ی یک قسط — هیچ‌وقت مستقیم ذخیره نمی‌شود، همیشه از روی
/// مبلغِ پرداخت‌شده و تاریخِ سررسید نسبت به «امروز» به‌صورت زنده محاسبه
/// می‌شود، تا اگر چند روز از تاریخ سررسید گذشت، خودش «معوق» بشه بدون اینکه
/// کسی دستی چیزی را تغییر داده باشد.
enum InstallmentStatus { paid, overdue, upcoming }

String installmentStatusLabel(InstallmentStatus s) {
  switch (s) {
    case InstallmentStatus.paid:
      return 'پرداخت‌شده';
    case InstallmentStatus.overdue:
      return 'معوق';
    case InstallmentStatus.upcoming:
      return 'در انتظار سررسید';
  }
}

Jalali? parseJalali(String? s) {
  if (s == null || !s.contains('/')) return null;
  try {
    final p = s.split('/').map(int.parse).toList();
    return Jalali(p[0], p[1], p[2]);
  } catch (_) {
    return null;
  }
}

String formatJalali(Jalali j) {
  return '${j.year.toString().padLeft(4, '0')}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

InstallmentStatus installmentStatus(Map<String, dynamic> inst) {
  final amount = toNum(inst['amount']);
  final paid = toNum(inst['paidAmount']);
  if (amount > 0 && paid >= amount) return InstallmentStatus.paid;
  final due = parseJalali(inst['dueDate']?.toString());
  if (due != null && due.toDateTime().isBefore(Jalali.now().toDateTime())) {
    return InstallmentStatus.overdue;
  }
  return InstallmentStatus.upcoming;
}

/// ساختِ خودکارِ اقساطِ مساوی. باقی‌مانده‌ی تقسیم (به‌خاطر گرد شدن) به قسطِ
/// آخر اضافه می‌شود تا مجموعِ دقیقِ اقساط همیشه با (مبلغ کل - پیش‌پرداخت)
/// برابر باشد — یک اصلِ ساده‌ی حسابداری که جمعِ جزئیات باید با کل برابر بماند.
List<Map<String, dynamic>> generateEqualInstallments({
  required double totalAmount,
  required double downPayment,
  required int count,
  required String firstDueDate,
  required int intervalDays,
}) {
  final remaining = totalAmount - downPayment;
  final base = (remaining / count).floorToDouble();
  final firstDue = parseJalali(firstDueDate) ?? Jalali.now();
  final installments = <Map<String, dynamic>>[];
  double allocated = 0;
  for (var i = 0; i < count; i++) {
    final isLast = i == count - 1;
    final amount = isLast ? (remaining - allocated) : base;
    allocated += amount;
    final due = firstDue.addDays(intervalDays * i);
    installments.add({
      'id': 'inst_${DateTime.now().microsecondsSinceEpoch}_$i',
      'index': i + 1,
      'dueDate': formatJalali(due),
      'amount': amount,
      'paidAmount': 0,
      'paidDate': null,
    });
  }
  return installments;
}

/// تخصیصِ یک پرداختِ دریافتی به اقساط، طبق اصلِ FIFO در حسابداریِ مطالبات:
/// پرداخت همیشه اول بدهیِ قدیمی‌ترین قسطِ بازشده (بر اساس تاریخ سررسید) را
/// می‌پوشاند، نه هر قسطی که کاربر دلش بخواهد. این دقیقاً همان منطقی است که
/// در حساب‌داریِ واقعیِ مطالبات مشتری (Accounts Receivable) استفاده می‌شود.
/// خروجی: مبلغِ اضافه‌ای که به هیچ قسطی نچسبید (اگر پرداخت از کل بدهی بیشتر بود).
double applyPaymentFifo(
  List<Map<String, dynamic>> installments,
  double paymentAmount,
  String paidDate,
) {
  final sorted = [...installments]
    ..sort((a, b) => (a['dueDate'] as String).compareTo(b['dueDate'] as String));
  double remainingPayment = paymentAmount;
  for (final inst in sorted) {
    if (remainingPayment <= 0) break;
    final amount = toNum(inst['amount']);
    final alreadyPaid = toNum(inst['paidAmount']);
    final owed = amount - alreadyPaid;
    if (owed <= 0) continue;
    final applied = remainingPayment >= owed ? owed : remainingPayment;
    inst['paidAmount'] = alreadyPaid + applied;
    inst['paidDate'] = paidDate;
    remainingPayment -= applied;
  }
  return remainingPayment;
}

List<Map<String, dynamic>> _installmentsOf(Map<String, dynamic> treatment) {
  final raw = treatment['installments'];
  if (raw is List) return raw.cast<Map<String, dynamic>>();
  return const [];
}

/// جمعِ کلِ دریافت‌شده از این ویزیت — چه قسطی باشد (جمعِ paidAmount همه‌ی
/// اقساط) چه نقدی (مستقیم از فیلدِ paidAmount خودِ ویزیت).
double treatmentTotalPaid(Map<String, dynamic> treatment) {
  final list = _installmentsOf(treatment);
  if (list.isEmpty) return toNum(treatment['paidAmount']);
  return list.fold<double>(0, (s, i) => s + toNum(i['paidAmount']));
}

double treatmentRemaining(Map<String, dynamic> treatment) {
  final remaining = toNum(treatment['totalAmount']) - treatmentTotalPaid(treatment);
  return remaining < 0 ? 0 : remaining;
}

bool treatmentHasOverdue(Map<String, dynamic> treatment) {
  for (final i in _installmentsOf(treatment)) {
    if (installmentStatus(i) == InstallmentStatus.overdue) return true;
  }
  return false;
}

bool treatmentIsSettled(Map<String, dynamic> treatment) => treatmentRemaining(treatment) <= 0;

/// نزدیک‌ترین سررسیدِ پرداخت‌نشده — برای نمایش «سررسید بعدی» در لیست.
Map<String, dynamic>? treatmentNextDueInstallment(Map<String, dynamic> treatment) {
  final unpaid = _installmentsOf(treatment)
      .where((i) => installmentStatus(i) != InstallmentStatus.paid)
      .toList()
    ..sort((a, b) => (a['dueDate'] as String).compareTo(b['dueDate'] as String));
  return unpaid.isEmpty ? null : unpaid.first;
}

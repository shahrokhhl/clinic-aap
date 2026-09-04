import 'dart:math';
import 'package:flutter/foundation.dart';
import '../config/formatters.dart';

/// داده‌ی نمایشیِ درون‌حافظه‌ای — تا بتوانید همین امروز، بدون بک‌اند فاز ۲،
/// ظاهر و رفتار کامل برنامه را ببینید و تست کنید. ساختار متدها دقیقاً
/// همان چیزی است که ApiService (سرویس واقعی) هم پیاده می‌کند، پس جابه‌جایی
/// بین این دو فقط یک خط در main.dart است.
class MockDataService extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _store = {};
  final _rand = Random();

  MockDataService() {
    _seed();
  }

  List<Map<String, dynamic>> rows(String moduleKey) => List.unmodifiable(_store[moduleKey] ?? []);

  /// «by» یعنی نام کاربرِ لاگین‌شده‌ای که این عملیات را انجام می‌دهد — برای
  /// حسابرسی (Audit Trail): مشخص شدنِ اینکه چه کسی چه رکوردی را ثبت یا
  /// ویرایش کرده، تا در صورت بروزِ مشکل یا نیاز به پیگیری، قابلِ ردیابی باشد.
  /// این فیلدها (که با «_» شروع می‌شوند) عمداً هیچ‌وقت در تعریفِ ستون‌های
  /// جدولِ ماژول‌ها (modules_config.dart) قرار نمی‌گیرند، پس نه در جدولِ
  /// اصلی نمایش داده می‌شوند و نه هیچ‌وقت باید در فیش/گزارشِ چاپیِ بیمار
  /// استفاده شوند — فقط از طریق دکمه‌ی «اطلاعاتِ ثبت» در دسترس‌اند.
  Future<Map<String, dynamic>> addRow(String moduleKey, Map<String, dynamic> row, {String? by}) async {
    row['id'] = 'r${_rand.nextInt(999999)}';
    row['_createdBy'] = by ?? 'ناشناس';
    row['_createdAt'] = nowJalaliStamp();
    _store.putIfAbsent(moduleKey, () => []).insert(0, row);
    notifyListeners();
    return row;
  }

  Future<void> updateRow(String moduleKey, String id, Map<String, dynamic> row, {String? by}) async {
    final list = _store[moduleKey];
    if (list == null) return;
    final idx = list.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      final old = list[idx];
      list[idx] = {
        ...row,
        'id': id,
        // اطلاعاتِ ثبتِ اولیه هرگز پاک نمی‌شود، فقط اطلاعاتِ ویرایش اضافه می‌شود
        '_createdBy': old['_createdBy'],
        '_createdAt': old['_createdAt'],
        '_updatedBy': by ?? 'ناشناس',
        '_updatedAt': nowJalaliStamp(),
      };
      notifyListeners();
    }
  }

  Future<void> deleteRow(String moduleKey, String id) async {
    _store[moduleKey]?.removeWhere((r) => r['id'] == id);
    notifyListeners();
  }

  void _seed() {
    _store['services'] = [
      {
        'id': 's1', 'date': '1403/06/10', 'patient': 'زهرا محمدی', 'item': 'کاردرمانی',
        'doctor': 'دکتر احمدی', 'supervisor': 'کلینیک', 'amount': 1200000,
        'method': 'کارتخوان', 'receiveStatus': 'دریافت شده', 'settleSup': 'تسویه شده',
        'refType': 'بدون ارجاع', 'refDoctor': '', 'refPercent': 0, 'settleRef': 'تسویه شده',
      },
      {
        'id': 's2', 'date': '1403/06/11', 'patient': 'علی رضایی', 'item': 'گفتاردرمانی',
        'doctor': 'دکتر کریمی', 'supervisor': 'خانم صادقی', 'amount': 950000,
        'method': 'نقدی', 'receiveStatus': 'دریافت شده', 'settleSup': 'تسویه نشده',
        'supPercent': 0.3, 'refType': 'خارج', 'refDoctor': 'دکتر موسوی', 'refPercent': 0.1,
        'settleRef': 'تسویه نشده',
      },
      {
        'id': 's3', 'date': '1403/06/12', 'patient': 'مریم حسینی', 'item': 'فیزیوتراپی',
        'doctor': 'دکتر احمدی', 'supervisor': 'کلینیک', 'amount': 1500000,
        'method': 'آنلاین', 'receiveStatus': 'دریافت نشده', 'settleSup': 'تسویه نشده',
        'refType': 'بدون ارجاع', 'refDoctor': '', 'refPercent': 0, 'settleRef': 'تسویه شده',
      },
      {
        'id': 's4', 'date': '1403/06/13', 'patient': 'حسین یوسفی', 'item': 'کاردرمانی',
        'doctor': 'دکتر کریمی', 'supervisor': 'خانم صادقی', 'amount': 1200000,
        'method': 'کارتخوان', 'receiveStatus': 'دریافت شده', 'settleSup': 'تسویه نشده',
        'supPercent': 0.3, 'refType': 'خارج', 'refDoctor': 'دکتر موسوی', 'refPercent': 0.1,
        'settleRef': 'تسویه نشده',
      },
    ];
    _store['visits'] = [
      {
        'id': 'v1', 'date': '1403/06/10', 'patient': 'حسین یوسفی', 'therapist': 'دکتر نوری',
        'baseAmount': 800000, 'overtime': 0, 'settleStatus': 'تسویه شده',
      },
      {
        'id': 'v2', 'date': '1403/06/12', 'patient': 'سارا احمدی', 'therapist': 'دکتر نوری',
        'baseAmount': 800000, 'overtime': 200000, 'settleStatus': 'تسویه نشده',
      },
    ];
    _store['patients'] = [
      {
        'id': 'p1', 'firstName': 'زهرا', 'lastName': 'محمدی', 'nationalCode': '0012345678',
        'mobile': '09121234567', 'gender': 'زن',
      },
      {
        'id': 'p2', 'firstName': 'علی', 'lastName': 'رضایی', 'nationalCode': '0023456789',
        'mobile': '09151234567', 'gender': 'مرد',
      },
    ];
    _store['expenses'] = [
      {'id': 'e1', 'date': '1403/06/09', 'category': 'اجاره', 'desc': 'اجاره ماهانه', 'amount': 25000000, 'method': 'کارتخوان'},
      {'id': 'e2', 'date': '1403/06/11', 'category': 'ملزومات', 'desc': 'خرید ملزومات پزشکی', 'amount': 3200000, 'method': 'نقدی'},
    ];
    _store['wechsler'] = [
      {
        'id': 'w1', 'date': '1403/06/08', 'patient': 'کیان رستمی', 'doctor': 'دکتر احمدی',
        'amount': 1800000, 'percent': 0.2, 'settleStatus': 'تسویه نشده',
      },
      {
        'id': 'w2', 'date': '1403/06/13', 'patient': 'نگار طاهری', 'doctor': 'دکتر کریمی',
        'amount': 1800000, 'percent': 0.2, 'settleStatus': 'تسویه شده',
      },
    ];
    _store['insurance'] = [
      {
        'id': 'i1', 'date': '1403/06/07', 'patient': 'رضا قاسمی', 'refDoctor': 'دکتر موسوی',
        'supervisor': 'کلینیک', 'item': 'فیزیوتراپی', 'insurer': 'تامین اجتماعی',
        'franchisePercent': 0.1, 'amount': 1400000, 'receivedFromPatient': 140000,
        'collectedFromInsurance': 1100000, 'deduction': 160000, 'status': 'وصول‌شده',
      },
      {
        'id': 'i2', 'date': '1403/06/12', 'patient': 'الهام صادقی', 'refDoctor': 'دکتر موسوی',
        'supervisor': 'کلینیک', 'item': 'کاردرمانی', 'insurer': 'بیمه سلامت',
        'franchisePercent': 0.1, 'amount': 1200000, 'receivedFromPatient': 120000,
        'collectedFromInsurance': 0, 'deduction': 0, 'status': 'در انتظار ارسال',
      },
    ];
    _store['receipts'] = [
      {'id': 'rc1', 'date': '1403/06/10', 'patient': 'زهرا محمدی', 'amount': 1200000, 'method': 'کارتخوان', 'desc': 'بابت ثبت خدمت'},
      {'id': 'rc2', 'date': '1403/06/12', 'patient': 'مریم حسینی', 'amount': 500000, 'method': 'نقدی', 'desc': 'پیش‌پرداخت'},
    ];
    _store['bank'] = [
      {'id': 'b1', 'date': '1403/06/05', 'type': 'واریز', 'account': 'حساب اصلی', 'desc': 'واریز درآمد هفتگی', 'amount': 18500000, 'method': 'آنلاین', 'party': '—'},
      {'id': 'b2', 'date': '1403/06/09', 'type': 'برداشت', 'account': 'حساب اصلی', 'desc': 'پرداخت اجاره', 'amount': 25000000, 'method': 'کارتخوان', 'party': 'مالک ساختمان'},
    ];
    _store['creditors'] = [
      {'id': 'cr1', 'date': '1403/06/01', 'name': 'دکتر نوری', 'type': 'درمانگر', 'debt': 4800000, 'paid': 3000000, 'status': 'بخشی پرداخت‌شده'},
      {'id': 'cr2', 'date': '1403/06/03', 'name': 'شرکت تجهیزات پزشکی الف', 'type': 'تامین‌کننده', 'debt': 6200000, 'paid': 0, 'status': 'باز'},
    ];
    _store['receivables'] = [
      {'id': 'rv1', 'date': '1403/06/12', 'patient': 'مریم حسینی', 'service': 'فیزیوتراپی', 'amount': 1500000, 'received': 0, 'status': 'باز'},
      {'id': 'rv2', 'date': '1403/06/06', 'patient': 'حسین یوسفی', 'service': 'کاردرمانی', 'amount': 950000, 'received': 500000, 'status': 'بخشی پرداخت‌شده'},
    ];
    _store['settingsServices'] = [
      {'id': 'sv1', 'name': 'کاردرمانی', 'income': 1200000, 'cost': 150000, 'defaultPercent': 0.3, 'active': true},
      {'id': 'sv2', 'name': 'گفتاردرمانی', 'income': 950000, 'cost': 100000, 'defaultPercent': 0.3, 'active': true},
      {'id': 'sv3', 'name': 'فیزیوتراپی', 'income': 1500000, 'cost': 200000, 'defaultPercent': 0.25, 'active': true},
    ];
    _store['therapists'] = [
      {'id': 'th1', 'name': 'دکتر نوری', 'percent': 0.35, 'note': 'کاردرمانی و گفتاردرمانی'},
      {'id': 'th2', 'name': 'دکتر رضوی', 'percent': 0.3, 'note': 'فیزیوتراپی'},
    ];
    _store['supervisors'] = [
      {'id': 'sp1', 'name': 'خانم صادقی', 'status': 'فعال', 'note': 'سرپرست شیفت صبح'},
      {'id': 'sp2', 'name': 'آقای کریمی', 'status': 'فعال', 'note': 'سرپرست شیفت عصر'},
    ];
    _store['users'] = [
      {'id': 'u1', 'fullName': 'مدیر سیستم', 'username': 'admin', 'password': 'admin123', 'role': 'مدیر سیستم', 'active': 'فعال', 'note': ''},
      {'id': 'u2', 'fullName': 'سارا کریمی', 'username': 'sara.k', 'password': '1234', 'role': 'حسابدار', 'active': 'فعال', 'note': ''},
      {'id': 'u3', 'fullName': 'نیلوفر رضایی', 'username': 'nilofar.r', 'password': '1234', 'role': 'منشی/پذیرش', 'active': 'فعال', 'note': ''},
    ];
    _store['dental'] = [
      {
        'id': 'd1', 'date': '1403/04/10', 'patient': 'فرزاد کاظمی', 'doctor': 'دکتر یزدانی',
        'item': 'روکش دندان', 'totalAmount': 12000000, 'cost': 1800000, 'method': 'کارتخوان',
        'note': '۲ عدد روکش سرامیکی', 'installmentPlan': true, 'paidAmount': 2000000,
        'installments': [
          {'id': 'd1i1', 'index': 1, 'dueDate': '1403/05/10', 'amount': 3333333, 'paidAmount': 3333333, 'paidDate': '1403/05/09'},
          {'id': 'd1i2', 'index': 2, 'dueDate': '1403/06/10', 'amount': 3333333, 'paidAmount': 3333333, 'paidDate': '1403/06/11'},
          {'id': 'd1i3', 'index': 3, 'dueDate': '1403/07/10', 'amount': 3333334, 'paidAmount': 0, 'paidDate': null},
        ],
      },
      {
        'id': 'd2', 'date': '1403/06/05', 'patient': 'شیرین علوی', 'doctor': 'دکتر یزدانی',
        'item': 'ایمپلنت', 'totalAmount': 25000000, 'cost': 6000000, 'method': 'کارتخوان',
        'note': 'ایمپلنت یک واحد + ترمیم', 'installmentPlan': true, 'paidAmount': 5000000,
        'installments': [
          {'id': 'd2i1', 'index': 1, 'dueDate': '1403/06/20', 'amount': 6666666, 'paidAmount': 5000000, 'paidDate': '1403/06/18'},
          {'id': 'd2i2', 'index': 2, 'dueDate': '1403/07/20', 'amount': 6666666, 'paidAmount': 0, 'paidDate': null},
          {'id': 'd2i3', 'index': 3, 'dueDate': '1403/08/20', 'amount': 6666668, 'paidAmount': 0, 'paidDate': null},
        ],
      },
      {
        'id': 'd3', 'date': '1403/06/12', 'patient': 'کامران نجفی', 'doctor': 'دکتر رستمی',
        'item': 'جرم‌گیری و بروساژ', 'totalAmount': 1800000, 'cost': 150000, 'method': 'نقدی',
        'note': '', 'installmentPlan': false, 'paidAmount': 1800000,
      },
    ];
  }

  /// جمع درآمد ۶ ماه اخیر برای نمودار داشبورد (داده‌ی نمایشی)
  List<double> demoMonthlyIncome() => [18500000, 21200000, 19800000, 25400000, 23100000, 27600000];
}

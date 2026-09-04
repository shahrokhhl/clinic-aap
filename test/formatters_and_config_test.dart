import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_accounting/services/mock_data_service.dart';
import 'package:clinic_accounting/config/formatters.dart';
import 'package:clinic_accounting/config/modules_config.dart';

void main() {
  group('توابع فرمت‌کننده', () {
    test('fmtMoney عدد را با جداکننده‌ی هزارگان نمایش می‌دهد', () {
      expect(fmtMoney(1200000), '1,200,000');
      expect(fmtMoney('950000'), '950,000');
      expect(fmtMoney(null), '0');
    });

    test('fmtPercent عدد اعشاری را به درصد تبدیل می‌کند', () {
      expect(fmtPercent(0.15), '15٪');
      expect(fmtPercent(0.5), '50٪');
    });

    test('toNum رشته‌ی دارای کاما را درست تبدیل می‌کند', () {
      expect(toNum('1,200,000'), 1200000.0);
      expect(toNum(''), 0.0);
    });
  });

  group('پیکربندی ماژول‌ها', () {
    test('همه‌ی ماژول‌های اصلی تعریف شده‌اند', () {
      const expectedKeys = [
        'services', 'visits', 'wechsler', 'insurance', 'expenses',
        'receipts', 'bank', 'creditors', 'receivables',
        'settingsServices', 'therapists', 'supervisors', 'patients', 'users',
      ];
      for (final key in expectedKeys) {
        expect(modulesConfig.containsKey(key), true, reason: 'ماژول $key باید تعریف شده باشد');
      }
    });

    test('ماژول کاربران فیلد رمز عبور دارد ولی آن را در ستون جدول نشان نمی‌دهد', () {
      final users = modulesConfig['users']!;
      expect(users.fields.any((f) => f.key == 'password'), true);
      expect(users.columns.any((c) => c.key == 'password'), false,
          reason: 'رمز عبور هرگز نباید در جدولِ نمایش داده شود');
    });

    test('هر ماژول حداقل یک ستون برای نمایش جدول دارد', () {
      for (final entry in modulesConfig.entries) {
        expect(entry.value.columns.isNotEmpty, true,
            reason: 'ماژول ${entry.key} باید حداقل یک ستون داشته باشد');
      }
    });

    test('هر ماژول حداقل یک فیلد برای فرم ثبت دارد', () {
      for (final entry in modulesConfig.entries) {
        expect(entry.value.fields.isNotEmpty, true,
            reason: 'ماژول ${entry.key} باید حداقل یک فیلد داشته باشد');
      }
    });
  });

  group('MockDataService', () {
    test('افزودنِ رکورد جدید، اطلاعاتِ ثبت‌کننده (audit) را خودکار می‌زند', () async {
      final service = MockDataService();
      final added = await service.addRow('expenses', {'date': '1403/07/01', 'amount': 100000}, by: 'تستر');
      expect(added['_createdBy'], 'تستر');
      expect(added['_createdAt'], isNotNull);
      expect(added['_updatedBy'], isNull);
    });

    test('ویرایشِ رکورد، اطلاعاتِ ثبتِ اولیه را پاک نمی‌کند و ویرایش‌کننده را ثبت می‌کند', () async {
      final service = MockDataService();
      final added = await service.addRow('expenses', {'date': '1403/07/01', 'amount': 100000}, by: 'کاربر اول');
      await service.updateRow('expenses', added['id'], {'date': '1403/07/02', 'amount': 200000}, by: 'کاربر دوم');
      final updated = service.rows('expenses').firstWhere((r) => r['id'] == added['id']);
      expect(updated['_createdBy'], 'کاربر اول');
      expect(updated['_updatedBy'], 'کاربر دوم');
    });
    test('همه‌ی ماژول‌ها حداقل یک رکورد نمایشی دارند (به‌جز موارد عمداً خالی)', () {
      final service = MockDataService();
      const expectedSeeded = [
        'services', 'visits', 'patients', 'expenses', 'wechsler', 'insurance',
        'receipts', 'bank', 'creditors', 'receivables', 'settingsServices',
        'therapists', 'supervisors', 'users',
      ];
      for (final key in expectedSeeded) {
        expect(service.rows(key).isNotEmpty, true, reason: 'ماژول $key باید داده‌ی نمایشی داشته باشد');
      }
    });
    test('افزودن یک ردیف جدید به لیست اضافه می‌شود', () async {
      final service = MockDataService();
      final before = service.rows('expenses').length;
      await service.addRow('expenses', {'date': '1403/07/01', 'amount': 100000});
      expect(service.rows('expenses').length, before + 1);
    });

    test('حذف یک ردیف، آن را از لیست پاک می‌کند', () async {
      final service = MockDataService();
      final added = await service.addRow('expenses', {'date': '1403/07/01', 'amount': 100000});
      final before = service.rows('expenses').length;
      await service.deleteRow('expenses', added['id']);
      expect(service.rows('expenses').length, before - 1);
    });
  });
}

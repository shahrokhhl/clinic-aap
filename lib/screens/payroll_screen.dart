import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/formatters.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

/// یک ردیفِ محاسبه‌شده برای فیش تسویه — از کدام ماژول آمده، بابت چه
/// مراجعه‌ای، و سهم این شخص از آن چقدر است.
class _PayrollLine {
  final String source; // نام ماژول مبدا (خدمات/ویزیت/وکسلر/بیمه)
  final String date;
  final String patient;
  final double amount; // سهم محاسبه‌شده (نه کل مبلغ خدمت)
  const _PayrollLine(this.source, this.date, this.patient, this.amount);
}

/// «فیش تسویه‌حساب» برخلاف بقیه‌ی ماژول‌ها یک جدولِ ثبت اطلاعات نیست؛
/// یک گزارشِ محاسبه‌شده است — دقیقاً معادل چیزی که در نسخه‌ی پایتونی با
/// print_report.py تولید می‌شد: برای یک نفر (درمانگر/سوپروایزر/دکتر
/// ارجاع‌دهنده)، همه‌ی رکوردهای «تسویه‌نشده»‌ی مربوط به او را از تمام
/// ماژول‌ها جمع می‌زند و مبلغ نهاییِ قابل‌پرداخت را نشان می‌دهد.
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String personType = 'سوپروایزر'; // 'سوپروایزر' | 'درمانگر' | 'دکتر ارجاع‌دهنده'
  String? selectedName;

  List<String> _namesFor(MockDataService data, String type) {
    final names = <String>{};
    switch (type) {
      case 'سوپروایزر':
        for (final r in data.rows('services')) {
          final n = r['supervisor']?.toString();
          if (n != null && n.isNotEmpty && n != 'کلینیک') names.add(n);
        }
        break;
      case 'درمانگر':
        for (final r in data.rows('visits')) {
          final n = r['therapist']?.toString();
          if (n != null && n.isNotEmpty) names.add(n);
        }
        break;
      case 'دکتر ارجاع‌دهنده':
        for (final r in data.rows('services')) {
          final n = r['refDoctor']?.toString();
          if (n != null && n.isNotEmpty) names.add(n);
        }
        for (final r in data.rows('insurance')) {
          final n = r['refDoctor']?.toString();
          if (n != null && n.isNotEmpty) names.add(n);
        }
        break;
    }
    return names.toList()..sort();
  }

  List<_PayrollLine> _computeLines(MockDataService data, String type, String name) {
    final lines = <_PayrollLine>[];

    if (type == 'سوپروایزر') {
      for (final r in data.rows('services')) {
        if (r['supervisor'] == name && r['settleSup'] == 'تسویه نشده') {
          final percent = toNum(r['supPercent']);
          final share = toNum(r['amount']) * (percent > 0 ? percent : 0.3); // پیش‌فرض ۳۰٪ اگر درصد ثبت نشده
          lines.add(_PayrollLine('ثبت خدمات', r['date']?.toString() ?? '', r['patient']?.toString() ?? '', share));
        }
      }
    } else if (type == 'درمانگر') {
      for (final r in data.rows('visits')) {
        if (r['therapist'] == name && r['settleStatus'] == 'تسویه نشده') {
          final total = toNum(r['baseAmount']) + toNum(r['overtime']);
          lines.add(_PayrollLine('ویزیت درمانگران', r['date']?.toString() ?? '', r['patient']?.toString() ?? '', total));
        }
      }
    } else if (type == 'دکتر ارجاع‌دهنده') {
      for (final r in data.rows('services')) {
        if (r['refDoctor'] == name && r['settleRef'] == 'تسویه نشده') {
          final percent = toNum(r['refPercent']);
          final share = toNum(r['amount']) * (percent > 0 ? percent : 0.1);
          lines.add(_PayrollLine('ثبت خدمات', r['date']?.toString() ?? '', r['patient']?.toString() ?? '', share));
        }
      }
      for (final r in data.rows('insurance')) {
        if (r['refDoctor'] == name) {
          lines.add(_PayrollLine('بیمه', r['date']?.toString() ?? '', r['patient']?.toString() ?? '', 0));
        }
      }
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockDataService>();
    final names = _namesFor(data, personType);
    if (selectedName != null && !names.contains(selectedName)) selectedName = null;
    final lines = selectedName == null ? <_PayrollLine>[] : _computeLines(data, personType, selectedName!);
    final total = lines.fold<double>(0, (s, l) => s + l.amount);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فیش تسویه حساب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'مبلغِ قابل‌پرداخت به هر شخص، محاسبه‌شده از رکوردهای تسویه‌نشده',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: personType,
                  decoration: const InputDecoration(labelText: 'نوع شخص'),
                  items: const [
                    DropdownMenuItem(value: 'سوپروایزر', child: Text('سوپروایزر')),
                    DropdownMenuItem(value: 'درمانگر', child: Text('درمانگر')),
                    DropdownMenuItem(value: 'دکتر ارجاع‌دهنده', child: Text('دکتر ارجاع‌دهنده')),
                  ],
                  onChanged: (v) => setState(() {
                    personType = v!;
                    selectedName = null;
                  }),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedName,
                  decoration: const InputDecoration(labelText: 'انتخاب نام'),
                  items: [for (final n in names) DropdownMenuItem(value: n, child: Text(n))],
                  onChanged: (v) => setState(() => selectedName = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (selectedName == null)
            const Expanded(
              child: Center(
                child: Text('یک نفر را برای مشاهده‌ی فیش تسویه انتخاب کنید',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$personType: $selectedName',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('${lines.length} رکورد تسویه‌نشده',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Text('${fmtMoney(total)} تومان',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final l = lines[i];
                    return ListTile(
                      title: Text(l.patient.isEmpty ? '—' : l.patient),
                      subtitle: Text('${l.source} • ${l.date}'),
                      trailing: Text('${fmtMoney(l.amount)} تومان',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: lines.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'برای چاپ/خروجی PDF این فیش، لازم است بک‌اند فاز ۲ و قالب چاپ متصل شود.')),
                        );
                      },
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('چاپ فیش'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

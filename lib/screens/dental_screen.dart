import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/formatters.dart';
import '../services/dental_logic.dart';
import '../services/mock_data_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/audit_info_dialog.dart';
import '../widgets/jalali_date_picker.dart';

const kDentalMethods = ['نقدی', 'کارتخوان', 'آنلاین', 'بیمه', 'چک'];

class DentalScreen extends StatefulWidget {
  const DentalScreen({super.key});

  @override
  State<DentalScreen> createState() => _DentalScreenState();
}

class _DentalScreenState extends State<DentalScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text('دندانپزشکی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddTreatmentSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('ثبت ویزیت جدید'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.blue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.blue,
          tabs: const [
            Tab(text: 'ویزیت‌های ثبت‌شده'),
            Tab(text: 'گزارش سررسید اقساط'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [_TreatmentListTab(), _DueReportTab()],
          ),
        ),
      ],
    );
  }

  void _openAddTreatmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddTreatmentSheet(),
    );
  }
}

// ============================================================================
// تب اول: لیست ویزیت‌ها
// ============================================================================

class _TreatmentListTab extends StatelessWidget {
  const _TreatmentListTab();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockDataService>();
    final rows = data.rows('dental');

    if (rows.isEmpty) {
      return const Center(
        child: Text('هنوز ویزیت دندانپزشکی ثبت نشده', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: rows.length,
      itemBuilder: (ctx, i) => _TreatmentCard(treatment: rows[i]),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final Map<String, dynamic> treatment;
  const _TreatmentCard({required this.treatment});

  @override
  Widget build(BuildContext context) {
    final hasInstallments = treatment['installmentPlan'] == true;
    final total = toNum(treatment['totalAmount']);
    final paid = treatmentTotalPaid(treatment);
    final remaining = treatmentRemaining(treatment);
    final settled = treatmentIsSettled(treatment);
    final overdue = treatmentHasOverdue(treatment);
    final nextDue = treatmentNextDueInstallment(treatment);

    Color badgeColor;
    String badgeText;
    if (settled) {
      badgeColor = AppColors.green;
      badgeText = 'تسویه کامل';
    } else if (overdue) {
      badgeColor = AppColors.red;
      badgeText = 'قسط معوق دارد';
    } else if (hasInstallments) {
      badgeColor = AppColors.amber;
      badgeText = 'در حال پرداخت';
    } else {
      badgeColor = AppColors.amber;
      badgeText = 'پرداخت‌نشده';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => _TreatmentDetailSheet(treatmentId: treatment['id']),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${treatment['patient'] ?? '—'}  •  ${treatment['item'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${treatment['date'] ?? ''} • ${treatment['doctor'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(label: 'مبلغ کل', value: fmtMoney(total)),
                  const SizedBox(width: 18),
                  _MiniStat(label: 'دریافت‌شده', value: fmtMoney(paid)),
                  const SizedBox(width: 18),
                  _MiniStat(label: 'باقی‌مانده', value: fmtMoney(remaining)),
                ],
              ),
              if (hasInstallments && nextDue != null && !settled) ...[
                const SizedBox(height: 10),
                Text(
                  'سررسید بعدی: ${nextDue['dueDate']} — مبلغ ${fmtMoney(toNum(nextDue['amount']) - toNum(nextDue['paidAmount']))} تومان',
                  style: TextStyle(fontSize: 12, color: overdue ? AppColors.red : AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ============================================================================
// تب دوم: گزارشِ سررسیدِ اقساط — همه‌ی بیمارها با هم، مرتب‌شده بر سررسید
// ============================================================================

class _DueReportTab extends StatelessWidget {
  const _DueReportTab();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockDataService>();
    final treatments = data.rows('dental').where((t) => t['installmentPlan'] == true).toList();

    final rows = <Map<String, dynamic>>[];
    for (final t in treatments) {
      final list = (t['installments'] as List?) ?? [];
      for (final raw in list) {
        final inst = Map<String, dynamic>.from(raw as Map);
        rows.add({...inst, 'patient': t['patient'], 'item': t['item'], 'treatmentId': t['id']});
      }
    }
    rows.sort((a, b) => (a['dueDate'] as String).compareTo(b['dueDate'] as String));

    final overdueTotal = rows
        .where((r) => installmentStatus(r) == InstallmentStatus.overdue)
        .fold<double>(0, (s, r) => s + (toNum(r['amount']) - toNum(r['paidAmount'])));

    if (rows.isEmpty) {
      return const Center(
        child: Text('هیچ ویزیتِ قسطی‌ای ثبت نشده', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppGradients.danger, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('جمعِ کلِ اقساطِ معوق', style: TextStyle(color: Colors.white, fontSize: 13)),
              Text('${fmtMoney(overdueTotal)} تومان',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final r = rows[i];
              final status = installmentStatus(r);
              final remaining = toNum(r['amount']) - toNum(r['paidAmount']);
              Color color = status == InstallmentStatus.paid
                  ? AppColors.green
                  : status == InstallmentStatus.overdue
                      ? AppColors.red
                      : AppColors.amber;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${r['patient']} — ${r['item']}'),
                subtitle: Text('سررسید: ${r['dueDate']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(installmentStatusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      status == InstallmentStatus.paid ? '${fmtMoney(r['amount'])} تومان' : '${fmtMoney(remaining)} تومان باقی',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// شیتِ جزئیاتِ یک ویزیت — لیستِ اقساط + ثبت پرداخت
// ============================================================================

class _TreatmentDetailSheet extends StatelessWidget {
  final String treatmentId;
  const _TreatmentDetailSheet({required this.treatmentId});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockDataService>();
    final treatment = data.rows('dental').firstWhere((t) => t['id'] == treatmentId, orElse: () => {});
    if (treatment.isEmpty) return const SizedBox.shrink();

    final installments = ((treatment['installments'] as List?) ?? []).cast<Map<String, dynamic>>();
    final hasInstallments = treatment['installmentPlan'] == true;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 44, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${treatment['patient']} — ${treatment['item']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
                      tooltip: 'اطلاعات ثبت',
                      onPressed: () => showAuditInfoDialog(context, treatment),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        _MiniStat(label: 'مبلغ کل', value: fmtMoney(treatment['totalAmount'])),
                        const SizedBox(width: 20),
                        _MiniStat(label: 'دریافت‌شده', value: fmtMoney(treatmentTotalPaid(treatment))),
                        const SizedBox(width: 20),
                        _MiniStat(label: 'باقی‌مانده', value: fmtMoney(treatmentRemaining(treatment))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (hasInstallments) ...[
                      const Text('اقساط', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      for (final inst in installments) _InstallmentTile(installment: inst),
                    ] else
                      const Text('این ویزیت به‌صورت نقدی/یک‌جا ثبت شده و قسط ندارد.',
                          style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!treatmentIsSettled(treatment))
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openRegisterPaymentDialog(context, treatment),
                      icon: const Icon(Icons.payments_outlined, size: 18),
                      label: const Text('ثبت پرداخت جدید'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openRegisterPaymentDialog(BuildContext context, Map<String, dynamic> treatment) {
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('ثبت پرداخت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'مبلغ دریافتی', suffixText: 'تومان'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'تاریخ دریافت', suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                onTap: () async {
                  final picked = await showJalaliDatePicker(ctx);
                  if (picked != null) setState(() => dateCtrl.text = picked);
                },
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'این مبلغ خودکار به قدیمی‌ترین قسطِ بازِ این بیمار تخصیص داده می‌شود (اصل FIFO).',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () {
                final amount = toNum(amountCtrl.text);
                if (amount <= 0 || dateCtrl.text.isEmpty) return;
                final installments = ((treatment['installments'] as List?) ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
                if (installments.isNotEmpty) {
                  applyPaymentFifo(installments, amount, dateCtrl.text);
                  final updated = {...treatment, 'installments': installments};
                  context.read<MockDataService>().updateRow('dental', treatment['id'], updated,
                      by: context.read<Session>().userName);
                } else {
                  final currentPaid = toNum(treatment['paidAmount']);
                  final updated = {...treatment, 'paidAmount': currentPaid + amount};
                  context.read<MockDataService>().updateRow('dental', treatment['id'], updated,
                      by: context.read<Session>().userName);
                }
                Navigator.pop(ctx);
              },
              child: const Text('ثبت'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  final Map<String, dynamic> installment;
  const _InstallmentTile({required this.installment});

  @override
  Widget build(BuildContext context) {
    final status = installmentStatus(installment);
    final color = status == InstallmentStatus.paid
        ? AppColors.green
        : status == InstallmentStatus.overdue
            ? AppColors.red
            : AppColors.amber;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('قسط ${installment['index']} — سررسید ${installment['dueDate']}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('${fmtMoney(installment['paidAmount'])} / ${fmtMoney(installment['amount'])} تومان',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(installmentStatusLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// شیتِ افزودنِ ویزیتِ جدید — با گزینه‌ی قسطی‌کردن
// ============================================================================

class _AddTreatmentSheet extends StatefulWidget {
  const _AddTreatmentSheet();

  @override
  State<_AddTreatmentSheet> createState() => _AddTreatmentSheetState();
}

class _AddTreatmentSheetState extends State<_AddTreatmentSheet> {
  final _dateCtrl = TextEditingController();
  final _patientCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _method = kDentalMethods.first;

  bool _isInstallment = false;
  final _downPaymentCtrl = TextEditingController(text: '0');
  final _countCtrl = TextEditingController(text: '3');
  final _intervalCtrl = TextEditingController(text: '30');
  final _firstDueCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_dateCtrl, _patientCtrl, _doctorCtrl, _itemCtrl, _totalCtrl, _costCtrl, _noteCtrl,
        _downPaymentCtrl, _countCtrl, _intervalCtrl, _firstDueCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 44, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('ثبت ویزیت دندانپزشکی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _labeledField('تاریخ ویزیت', TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                      onTap: () async {
                        final picked = await showJalaliDatePicker(context, initial: _dateCtrl.text);
                        if (picked != null) setState(() => _dateCtrl.text = picked);
                      },
                    )),
                    _labeledField('نام بیمار', TextField(controller: _patientCtrl)),
                    _labeledField('نام دندانپزشک', TextField(controller: _doctorCtrl)),
                    _labeledField('نوع درمان', TextField(controller: _itemCtrl, decoration: const InputDecoration(hintText: 'مثلاً روکش، کامپوزیت، ایمپلنت...'))),
                    _labeledField('مبلغ کل درمان', TextField(controller: _totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: 'تومان'))),
                    _labeledField('هزینه مصرفی', TextField(controller: _costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: 'تومان'))),
                    _labeledField('روش دریافت', DropdownButtonFormField<String>(
                      value: _method,
                      items: [for (final m in kDentalMethods) DropdownMenuItem(value: m, child: Text(m))],
                      onChanged: (v) => setState(() => _method = v!),
                    )),
                    _labeledField('توضیحات', TextField(controller: _noteCtrl)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('پرداخت قسطی می‌شود؟', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      value: _isInstallment,
                      onChanged: (v) => setState(() => _isInstallment = v),
                    ),
                    if (_isInstallment) ...[
                      _labeledField('پیش‌پرداخت (اختیاری)', TextField(controller: _downPaymentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: 'تومان'))),
                      _labeledField('تعداد اقساط', TextField(controller: _countCtrl, keyboardType: TextInputType.number)),
                      _labeledField('فاصله‌ی هر قسط (روز)', TextField(controller: _intervalCtrl, keyboardType: TextInputType.number)),
                      _labeledField('تاریخ سررسید قسط اول', TextField(
                        controller: _firstDueCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                        onTap: () async {
                          final picked = await showJalaliDatePicker(context, initial: _firstDueCtrl.text);
                          if (picked != null) setState(() => _firstDueCtrl.text = picked);
                        },
                      )),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _submit, child: const Text('ثبت ویزیت')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }

  void _submit() {
    final total = toNum(_totalCtrl.text);
    if (_patientCtrl.text.isEmpty || total <= 0) return;

    Map<String, dynamic> treatment = {
      'date': _dateCtrl.text,
      'patient': _patientCtrl.text,
      'doctor': _doctorCtrl.text,
      'item': _itemCtrl.text,
      'totalAmount': total,
      'cost': toNum(_costCtrl.text),
      'method': _method,
      'note': _noteCtrl.text,
      'installmentPlan': _isInstallment,
      'paidAmount': 0,
    };

    if (_isInstallment) {
      final downPayment = toNum(_downPaymentCtrl.text);
      final count = int.tryParse(_countCtrl.text) ?? 1;
      final interval = int.tryParse(_intervalCtrl.text) ?? 30;
      final installments = generateEqualInstallments(
        totalAmount: total,
        downPayment: downPayment,
        count: count < 1 ? 1 : count,
        firstDueDate: _firstDueCtrl.text,
        intervalDays: interval,
      );
      treatment['paidAmount'] = downPayment;
      treatment['installments'] = installments;
    }

    context.read<MockDataService>().addRow('dental', treatment, by: context.read<Session>().userName);
    Navigator.pop(context);
  }
}

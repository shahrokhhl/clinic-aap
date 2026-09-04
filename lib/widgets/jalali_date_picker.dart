import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../theme/app_theme.dart';

const _monthNames = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];
const _weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

/// دیالوگ انتخاب تاریخ شمسی — جایگزینِ TextField موقتیِ نسخه‌ی قبلی.
/// خروجی به‌فرمت YYYY/MM/DD برمی‌گردد، دقیقاً هماهنگ با فرمتِ نسخه‌ی
/// پایتونی برنامه.
Future<String?> showJalaliDatePicker(BuildContext context, {String? initial}) {
  Jalali initialDate;
  try {
    if (initial != null && initial.contains('/')) {
      final parts = initial.split('/').map(int.parse).toList();
      initialDate = Jalali(parts[0], parts[1], parts[2]);
    } else {
      initialDate = Jalali.now();
    }
  } catch (_) {
    initialDate = Jalali.now();
  }

  return showDialog<String>(
    context: context,
    builder: (ctx) => _JalaliPickerDialog(initial: initialDate),
  );
}

class _JalaliPickerDialog extends StatefulWidget {
  final Jalali initial;
  const _JalaliPickerDialog({required this.initial});

  @override
  State<_JalaliPickerDialog> createState() => _JalaliPickerDialogState();
}

class _JalaliPickerDialogState extends State<_JalaliPickerDialog> {
  late int year;
  late int month;
  late int? selectedDay;

  @override
  void initState() {
    super.initState();
    year = widget.initial.year;
    month = widget.initial.month;
    selectedDay = widget.initial.day;
  }

  @override
  Widget build(BuildContext context) {
    final monthLength = Jalali(year, month, 1).monthLength;
    final firstOfMonth = Jalali(year, month, 1);
    // در shamsi_date، weekDay بین ۱ تا ۷ است و شنبه=۱، جمعه=۷.
    // چون ستون اول چیدمان ما هم شنبه است، به ایندکس صفرمبنا تبدیل می‌کنیم.
    final firstWeekDay = firstOfMonth.weekDay - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    if (month == 1) {
                      month = 12;
                      year--;
                    } else {
                      month--;
                    }
                    selectedDay = null;
                  }),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_monthNames[month - 1]} $year',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    if (month == 12) {
                      month = 1;
                      year++;
                    } else {
                      month++;
                    }
                    selectedDay = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final d in _weekDays)
                  Expanded(
                    child: Center(
                      child: Text(d, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: monthLength + firstWeekDay,
                itemBuilder: (ctx, index) {
                  if (index < firstWeekDay) return const SizedBox.shrink();
                  final day = index - firstWeekDay + 1;
                  final isSelected = selectedDay == day;
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Material(
                      color: isSelected ? AppColors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => selectedDay = day),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedDay == null
                        ? null
                        : () {
                            final y = year.toString().padLeft(4, '0');
                            final m = month.toString().padLeft(2, '0');
                            final d = selectedDay!.toString().padLeft(2, '0');
                            Navigator.pop(context, '$y/$m/$d');
                          },
                    child: const Text('تأیید'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

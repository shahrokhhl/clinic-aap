import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// این دیالوگ اطلاعاتِ حسابرسی (چه کسی ثبت کرد، چه کسی آخرین بار ویرایش
/// کرد) را فقط داخلِ خودِ برنامه نشان می‌دهد. این فیلدها (_createdBy و...)
/// عمداً در تعریفِ ستون‌های هیچ ماژولی نیستند، پس در جدولِ اصلی یا در هر
/// فیش/گزارشِ چاپیِ بیمار ظاهر نمی‌شوند — فقط از همین دکمه قابل‌مشاهده‌اند.
void showAuditInfoDialog(BuildContext context, Map<String, dynamic> row) {
  final createdBy = row['_createdBy'] as String?;
  final createdAt = row['_createdAt'] as String?;
  final updatedBy = row['_updatedBy'] as String?;
  final updatedAt = row['_updatedAt'] as String?;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('اطلاعات ثبت و ویرایش', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuditRow(
            icon: Icons.person_add_alt_1_outlined,
            iconColor: AppColors.blue,
            title: 'ثبت‌شده توسط: ${createdBy ?? "نامشخص"}',
            subtitle: createdAt != null ? 'تاریخ ثبت: $createdAt' : null,
          ),
          if (updatedBy != null) ...[
            const Divider(height: 24),
            _AuditRow(
              icon: Icons.edit_note_outlined,
              iconColor: AppColors.amber,
              title: 'آخرین ویرایش توسط: $updatedBy',
              subtitle: updatedAt != null ? 'تاریخ ویرایش: $updatedAt' : null,
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('این رکورد بعد از ثبت، ویرایش نشده است.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
      ],
    ),
  );
}

class _AuditRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  const _AuditRow({required this.icon, required this.iconColor, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

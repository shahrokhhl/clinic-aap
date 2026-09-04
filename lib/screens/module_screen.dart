import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/modules_config.dart';
import '../services/mock_data_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_form.dart';
import '../widgets/dynamic_table.dart';

/// یک صفحه‌ی واحد و کاملاً پویا که برای هر ۱۳ ماژول (خدمات، ویزیت، بیمه،
/// هزینه‌ها و ...) استفاده می‌شود — دقیقاً همان فلسفه‌ی modules_config.py
/// در نسخه‌ی پایتونی: یک موتور، چند تعریف.
class ModuleScreen extends StatelessWidget {
  final String moduleKey;
  const ModuleScreen({super.key, required this.moduleKey});

  @override
  Widget build(BuildContext context) {
    final module = modulesConfig[moduleKey];
    if (module == null) {
      return const Center(child: Text('این بخش هنوز پیاده‌سازی نشده.'));
    }

    final data = context.watch<MockDataService>();
    final rows = data.rows(moduleKey);
    final summary = module.summary?.call(rows) ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(module.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDynamicFormSheet(context, module: module);
                  if (result != null) {
                    final by = context.read<Session>().userName;
                    await context.read<MockDataService>().addRow(moduleKey, result, by: by);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text('ثبت ${module.addLabel}'),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in summary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 3),
                        Text(item.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DynamicTable(
                  module: module,
                  rows: rows,
                  onEdit: (row) async {
                    final result = await showDynamicFormSheet(context, module: module, initial: row);
                    if (result != null) {
                      final by = context.read<Session>().userName;
                      await context.read<MockDataService>().updateRow(moduleKey, row['id'], result, by: by);
                    }
                  },
                  onDelete: (row) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('حذف رکورد'),
                        content: const Text('از حذف این رکورد مطمئن هستید؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('حذف', style: TextStyle(color: AppColors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await context.read<MockDataService>().deleteRow(moduleKey, row['id']);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/module_models.dart';
import '../theme/app_theme.dart';
import 'audit_info_dialog.dart';

class DynamicTable extends StatelessWidget {
  final ModuleDef module;
  final List<Map<String, dynamic>> rows;
  final void Function(Map<String, dynamic> row) onEdit;
  final void Function(Map<String, dynamic> row) onDelete;

  const DynamicTable({
    super.key,
    required this.module,
    required this.rows,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text('هنوز رکوردی برای «${module.title}» ثبت نشده',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.bg),
        columnSpacing: 28,
        columns: [
          for (final col in module.columns) DataColumn(label: Text(col.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
          const DataColumn(label: Text('')),
        ],
        rows: [
          for (final row in rows)
            DataRow(cells: [
              for (final col in module.columns)
                DataCell(Text(
                  col.calc != null ? col.calc!(row) : (row[col.key]?.toString() ?? '—'),
                  style: const TextStyle(fontSize: 13),
                )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                    onPressed: () => showAuditInfoDialog(context, row),
                    tooltip: 'اطلاعات ثبت',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.blue),
                    onPressed: () => onEdit(row),
                    tooltip: 'ویرایش',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                    onPressed: () => onDelete(row),
                    tooltip: 'حذف',
                  ),
                ],
              )),
            ]),
        ],
      ),
    );
  }
}

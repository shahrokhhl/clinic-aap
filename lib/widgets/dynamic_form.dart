import 'package:flutter/material.dart';
import '../models/module_models.dart';
import '../theme/app_theme.dart';
import 'jalali_date_picker.dart';

/// شیت پایین‌صفحه‌ای برای افزودن/ویرایش یک ردیف، کاملاً از روی
/// تعریف فیلدهای ماژول (ModuleDef.fields) ساخته می‌شود — یعنی برای
/// اضافه کردن یک ماژول تازه در آینده، کافی‌ست تعریفش را به
/// modules_config.dart اضافه کنید؛ این فرم خودش می‌سازدش.
Future<Map<String, dynamic>?> showDynamicFormSheet(
  BuildContext context, {
  required ModuleDef module,
  Map<String, dynamic>? initial,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DynamicFormSheet(module: module, initial: initial),
  );
}

class _DynamicFormSheet extends StatefulWidget {
  final ModuleDef module;
  final Map<String, dynamic>? initial;
  const _DynamicFormSheet({required this.module, this.initial});

  @override
  State<_DynamicFormSheet> createState() => _DynamicFormSheetState();
}

class _DynamicFormSheetState extends State<_DynamicFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    values = Map<String, dynamic>.from(widget.initial ?? {});
    for (final f in widget.module.fields) {
      if (f.type != FieldType.select && f.type != FieldType.boolean) {
        _controllers[f.key] = TextEditingController(text: values[f.key]?.toString() ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
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
                      child: Text(
                        isEdit ? 'ویرایش ${widget.module.addLabel}' : 'ثبت ${widget.module.addLabel} جدید',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    children: [
                      for (final field in widget.module.fields) _buildField(field),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEdit ? 'ذخیره تغییرات' : 'ثبت ${widget.module.addLabel}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(ModuleField field) {
    Widget input;
    switch (field.type) {
      case FieldType.select:
      case FieldType.boolean:
        final opts = field.options ?? [];
        final current = values[field.key]?.toString();
        input = DropdownButtonFormField<String>(
          value: opts.contains(current) ? current : null,
          items: [for (final o in opts) DropdownMenuItem(value: o, child: Text(o))],
          onChanged: (v) => setState(() => values[field.key] = v),
          validator: field.required ? (v) => v == null ? 'این فیلد الزامی است' : null : null,
        );
        break;
      case FieldType.date:
        input = TextFormField(
          controller: _controllers[field.key],
          readOnly: true,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
            hintText: '۱۴۰۳/۰۶/۱۰',
          ),
          onTap: () async {
            final picked = await showJalaliDatePicker(
              context,
              initial: _controllers[field.key]?.text,
            );
            if (picked != null) {
              setState(() => _controllers[field.key]!.text = picked);
            }
          },
          validator: field.required ? (v) => (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null : null,
        );
        break;
      case FieldType.money:
        input = TextFormField(
          controller: _controllers[field.key],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'تومان'),
          validator: field.required ? (v) => (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null : null,
        );
        break;
      case FieldType.percent:
        input = TextFormField(
          controller: _controllers[field.key],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: '٪'),
        );
        break;
      case FieldType.password:
        input = TextFormField(
          controller: _controllers[field.key],
          obscureText: true,
          validator: field.required ? (v) => (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null : null,
        );
        break;
      default:
        input = TextFormField(
          controller: _controllers[field.key],
          validator: field.required ? (v) => (v == null || v.isEmpty) ? 'این فیلد الزامی است' : null : null,
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          input,
          if (field.hint != null) ...[
            const SizedBox(height: 4),
            Text(field.hint!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    for (final f in widget.module.fields) {
      if (_controllers.containsKey(f.key)) {
        values[f.key] = _controllers[f.key]!.text;
      }
    }
    Navigator.pop(context, values);
  }
}

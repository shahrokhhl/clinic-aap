import '../models/module_models.dart';
import 'formatters.dart';

/// این فایل، ترجمه‌ی دقیقِ modules_config.py از نسخه‌ی پایتونی است — همان
/// کلیدها (key) عیناً حفظ شده‌اند تا وقتی به بک‌اند FastAPI وصل شدیم،
/// نیازی به نگاشتِ (mapping) دوباره‌ی فیلدها نباشد و مستقیم با هم صحبت کنند.

const kMethods = ['نقدی', 'کارتخوان', 'آنلاین', 'بیمه', 'چک'];
const kReceiveStatus = ['دریافت شده', 'دریافت نشده'];
const kSettleStatus = ['تسویه شده', 'تسویه نشده'];

final Map<String, ModuleDef> modulesConfig = {
  'services': ModuleDef(
    key: 'services',
    title: 'ثبت خدمات',
    addLabel: 'خدمت',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ مراجعه', type: FieldType.date, required: true),
      ModuleField(
        key: 'patient',
        label: 'نام بیمار',
        type: FieldType.patientPicker,
        hint: 'از پرونده‌های ثبت‌شده انتخاب کنید یا در همان لحظه بیمار جدید بسازید.',
        required: true,
      ),
      ModuleField(
        key: 'item',
        label: 'آیتم / دستگاه',
        type: FieldType.comboSettings,
        hint: 'با انتخاب یا تایپ نام دقیق آیتم، مبلغ/هزینهٔ پیش‌فرض آن به‌طور خودکار پر می‌شود.',
      ),
      ModuleField(key: 'doctor', label: 'نام دکتر ویزیت‌کننده', type: FieldType.comboFree),
      ModuleField(
        key: 'refType',
        label: 'نوع ارجاع',
        type: FieldType.select,
        options: ['بدون ارجاع', 'داخل', 'خارج'],
      ),
      ModuleField(
        key: 'refDoctor',
        label: 'دکتر ارجاع‌دهنده',
        type: FieldType.text,
        hint: 'فقط وقتی نوع ارجاع «خارج» باشد، سهم این دکتر محاسبه می‌شود.',
      ),
      ModuleField(
        key: 'supervisor',
        label: 'نام سوپروایزر',
        type: FieldType.comboFree,
        hint: 'اگر «کلینیک» انتخاب شود، هیچ پرداخت شخصی‌ای ثبت نمی‌شود.',
      ),
      ModuleField(key: 'amount', label: 'مبلغ دریافتی از بیمار', type: FieldType.money, required: true),
      ModuleField(key: 'cost', label: 'هزینه مصرفی', type: FieldType.money),
      ModuleField(key: 'supPercent', label: 'درصد سهم سوپروایزر', type: FieldType.percent),
      ModuleField(key: 'refPercent', label: 'درصد سهم دکتر ارجاع‌دهنده', type: FieldType.percent),
      ModuleField(key: 'method', label: 'روش دریافت', type: FieldType.select, options: kMethods),
      ModuleField(key: 'receiveStatus', label: 'وضعیت دریافت', type: FieldType.select, options: kReceiveStatus),
      ModuleField(key: 'settleSup', label: 'وضعیت تسویه سوپروایزر', type: FieldType.select, options: kSettleStatus),
      ModuleField(key: 'settleRef', label: 'وضعیت تسویه ارجاع‌دهنده', type: FieldType.select, options: kSettleStatus),
      ModuleField(key: 'receipt', label: 'شماره پیگیری/رسید', type: FieldType.text),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      const ModuleColumn(key: 'item', label: 'آیتم'),
      const ModuleColumn(key: 'doctor', label: 'دکتر ویزیت‌کننده'),
      const ModuleColumn(key: 'supervisor', label: 'سوپروایزر'),
      ModuleColumn(key: 'amount', label: 'مبلغ دریافتی', calc: (r) => fmtMoney(r['amount'])),
      ModuleColumn(key: 'settleSup', label: 'تسویه سوپروایزر'),
      ModuleColumn(key: 'receiveStatus', label: 'وضعیت دریافت'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      return [
        SummaryItem(label: 'تعداد خدمات', value: rows.length.toString()),
        SummaryItem(label: 'جمع دریافتی', value: fmtMoney(total)),
      ];
    },
  ),

  'visits': ModuleDef(
    key: 'visits',
    title: 'ویزیت درمانگران',
    addLabel: 'ویزیت',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ مراجعه', type: FieldType.date, required: true),
      ModuleField(key: 'patient', label: 'نام بیمار', type: FieldType.patientPicker, required: true),
      ModuleField(key: 'therapist', label: 'نام درمانگر', type: FieldType.comboFree),
      ModuleField(key: 'baseAmount', label: 'مبلغ اصلی ویزیت', type: FieldType.money),
      ModuleField(key: 'overtime', label: 'اضافه ساعت', type: FieldType.money),
      ModuleField(key: 'settleStatus', label: 'وضعیت تسویه', type: FieldType.select, options: kSettleStatus),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      const ModuleColumn(key: 'therapist', label: 'درمانگر'),
      ModuleColumn(
        key: 'total',
        label: 'جمع دریافتی',
        calc: (r) => fmtMoney(toNum(r['baseAmount']) + toNum(r['overtime'])),
      ),
      const ModuleColumn(key: 'settleStatus', label: 'وضعیت تسویه'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(
          0, (s, r) => s + toNum(r['baseAmount']) + toNum(r['overtime']));
      return [
        SummaryItem(label: 'تعداد ویزیت', value: rows.length.toString()),
        SummaryItem(label: 'جمع دریافتی', value: fmtMoney(total)),
      ];
    },
  ),

  'wechsler': ModuleDef(
    key: 'wechsler',
    title: 'تست وکسلر',
    addLabel: 'تست',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'patient', label: 'نام بیمار', type: FieldType.patientPicker, required: true),
      ModuleField(key: 'doctor', label: 'نام دکتر', type: FieldType.comboFree),
      ModuleField(key: 'amount', label: 'مبلغ تست', type: FieldType.money),
      ModuleField(key: 'percent', label: 'درصد سهم دکتر', type: FieldType.percent),
      ModuleField(key: 'settleStatus', label: 'وضعیت تسویه', type: FieldType.select, options: kSettleStatus),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      const ModuleColumn(key: 'doctor', label: 'دکتر'),
      ModuleColumn(key: 'amount', label: 'مبلغ تست', calc: (r) => fmtMoney(r['amount'])),
      const ModuleColumn(key: 'settleStatus', label: 'وضعیت تسویه'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      return [
        SummaryItem(label: 'تعداد تست', value: rows.length.toString()),
        SummaryItem(label: 'جمع مبلغ', value: fmtMoney(total)),
      ];
    },
  ),

  'insurance': ModuleDef(
    key: 'insurance',
    title: 'بیمه',
    addLabel: 'مراجعه بیمه‌ای',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'patient', label: 'نام بیمار', type: FieldType.patientPicker, required: true),
      ModuleField(key: 'refDoctor', label: 'دکتر ارجاع‌دهنده', type: FieldType.comboFree),
      ModuleField(key: 'supervisor', label: 'سوپروایزر', type: FieldType.comboFree),
      ModuleField(key: 'item', label: 'دستگاه / خدمت', type: FieldType.comboSettings),
      ModuleField(key: 'insurer', label: 'بیمه مراجعه‌کننده', type: FieldType.text),
      ModuleField(key: 'franchisePercent', label: 'درصد فرانشیز بیمار', type: FieldType.percent),
      ModuleField(key: 'amount', label: 'مبلغ اصلی خدمت', type: FieldType.money),
      ModuleField(key: 'receivedFromPatient', label: 'دریافتی از بیمار', type: FieldType.money),
      ModuleField(key: 'collectedFromInsurance', label: 'وصول‌شده از بیمه', type: FieldType.money),
      ModuleField(key: 'deduction', label: 'کسورات / اختلاف بیمه', type: FieldType.money),
      ModuleField(
        key: 'status',
        label: 'وضعیت بیمه',
        type: FieldType.select,
        options: ['در انتظار ارسال', 'ارسال‌شده', 'وصول‌شده', 'تسویه کامل'],
      ),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      const ModuleColumn(key: 'insurer', label: 'بیمه'),
      const ModuleColumn(key: 'item', label: 'خدمت'),
      ModuleColumn(key: 'amount', label: 'مبلغ اصلی', calc: (r) => fmtMoney(r['amount'])),
      const ModuleColumn(key: 'status', label: 'وضعیت'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      final collected = rows.fold<double>(0, (s, r) => s + toNum(r['collectedFromInsurance']));
      return [
        SummaryItem(label: 'تعداد پرونده', value: rows.length.toString()),
        SummaryItem(label: 'جمع مبلغ', value: fmtMoney(total)),
        SummaryItem(label: 'وصول‌شده', value: fmtMoney(collected)),
      ];
    },
  ),

  'expenses': ModuleDef(
    key: 'expenses',
    title: 'هزینه‌ها',
    addLabel: 'هزینه',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'category', label: 'دسته هزینه', type: FieldType.text),
      ModuleField(key: 'desc', label: 'شرح هزینه', type: FieldType.text),
      ModuleField(key: 'amount', label: 'مبلغ', type: FieldType.money, required: true),
      ModuleField(key: 'method', label: 'روش پرداخت', type: FieldType.select, options: kMethods),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'category', label: 'دسته'),
      const ModuleColumn(key: 'desc', label: 'شرح'),
      ModuleColumn(key: 'amount', label: 'مبلغ', calc: (r) => fmtMoney(r['amount'])),
      const ModuleColumn(key: 'method', label: 'روش پرداخت'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      return [
        SummaryItem(label: 'تعداد رکورد', value: rows.length.toString()),
        SummaryItem(label: 'جمع هزینه‌ها', value: fmtMoney(total)),
      ];
    },
  ),

  'receipts': ModuleDef(
    key: 'receipts',
    title: 'دریافت‌ها',
    addLabel: 'دریافتی',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'patient', label: 'نام بیمار', type: FieldType.text),
      ModuleField(key: 'amount', label: 'مبلغ', type: FieldType.money, required: true),
      ModuleField(key: 'method', label: 'روش دریافت', type: FieldType.select, options: kMethods),
      ModuleField(key: 'desc', label: 'شرح', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      ModuleColumn(key: 'amount', label: 'مبلغ', calc: (r) => fmtMoney(r['amount'])),
      const ModuleColumn(key: 'method', label: 'روش'),
    ],
    summary: (rows) {
      final total = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      return [
        SummaryItem(label: 'تعداد رکورد', value: rows.length.toString()),
        SummaryItem(label: 'جمع دریافتی', value: fmtMoney(total)),
      ];
    },
  ),

  'bank': ModuleDef(
    key: 'bank',
    title: 'حساب‌ها و بانک',
    addLabel: 'تراکنش',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'type', label: 'نوع تراکنش', type: FieldType.select, options: ['واریز', 'برداشت']),
      ModuleField(key: 'account', label: 'حساب', type: FieldType.text),
      ModuleField(key: 'desc', label: 'شرح', type: FieldType.text),
      ModuleField(key: 'amount', label: 'مبلغ', type: FieldType.money, required: true),
      ModuleField(key: 'method', label: 'روش', type: FieldType.select, options: kMethods),
      ModuleField(key: 'party', label: 'طرف حساب', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'type', label: 'نوع'),
      const ModuleColumn(key: 'account', label: 'حساب'),
      const ModuleColumn(key: 'party', label: 'طرف حساب'),
      ModuleColumn(key: 'amount', label: 'مبلغ', calc: (r) => fmtMoney(r['amount'])),
    ],
    summary: (rows) {
      final deposit = rows.where((r) => r['type'] == 'واریز').fold<double>(0, (s, r) => s + toNum(r['amount']));
      final withdraw = rows.where((r) => r['type'] == 'برداشت').fold<double>(0, (s, r) => s + toNum(r['amount']));
      return [
        SummaryItem(label: 'جمع واریز', value: fmtMoney(deposit)),
        SummaryItem(label: 'جمع برداشت', value: fmtMoney(withdraw)),
      ];
    },
  ),

  'creditors': ModuleDef(
    key: 'creditors',
    title: 'بستانکاران',
    addLabel: 'بستانکار',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'name', label: 'نام بستانکار', type: FieldType.text, required: true),
      ModuleField(
        key: 'type',
        label: 'نوع',
        type: FieldType.select,
        options: ['درمانگر', 'سوپروایزر', 'ارجاع‌دهنده', 'تامین‌کننده', 'سایر'],
      ),
      ModuleField(key: 'debt', label: 'مبلغ بدهی', type: FieldType.money),
      ModuleField(key: 'paid', label: 'مبلغ پرداخت‌شده', type: FieldType.money),
      ModuleField(
        key: 'status',
        label: 'وضعیت',
        type: FieldType.select,
        options: ['باز', 'تسویه شده', 'بخشی پرداخت‌شده'],
      ),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'name', label: 'نام'),
      const ModuleColumn(key: 'type', label: 'نوع'),
      ModuleColumn(key: 'debt', label: 'بدهی', calc: (r) => fmtMoney(r['debt'])),
      ModuleColumn(
        key: 'balance',
        label: 'مانده',
        calc: (r) => fmtMoney(toNum(r['debt']) - toNum(r['paid'])),
      ),
      const ModuleColumn(key: 'status', label: 'وضعیت'),
    ],
    summary: (rows) {
      final debt = rows.fold<double>(0, (s, r) => s + toNum(r['debt']));
      final balance = rows.fold<double>(0, (s, r) => s + toNum(r['debt']) - toNum(r['paid']));
      return [
        SummaryItem(label: 'جمع بدهی', value: fmtMoney(debt)),
        SummaryItem(label: 'مانده کل', value: fmtMoney(balance)),
      ];
    },
  ),

  'receivables': ModuleDef(
    key: 'receivables',
    title: 'مطالبات بیماران',
    addLabel: 'مطالبه',
    fields: const [
      ModuleField(key: 'date', label: 'تاریخ', type: FieldType.date, required: true),
      ModuleField(key: 'patient', label: 'نام بیمار', type: FieldType.text, required: true),
      ModuleField(key: 'service', label: 'نوع خدمت', type: FieldType.text),
      ModuleField(key: 'amount', label: 'مبلغ خدمت', type: FieldType.money),
      ModuleField(key: 'received', label: 'دریافت‌شده', type: FieldType.money),
      ModuleField(
        key: 'status',
        label: 'وضعیت',
        type: FieldType.select,
        options: ['باز', 'تسویه شده', 'بخشی پرداخت‌شده'],
      ),
    ],
    columns: [
      const ModuleColumn(key: 'date', label: 'تاریخ'),
      const ModuleColumn(key: 'patient', label: 'بیمار'),
      const ModuleColumn(key: 'service', label: 'خدمت'),
      ModuleColumn(key: 'amount', label: 'مبلغ خدمت', calc: (r) => fmtMoney(r['amount'])),
      ModuleColumn(
        key: 'balance',
        label: 'مانده',
        calc: (r) => fmtMoney(toNum(r['amount']) - toNum(r['received'])),
      ),
      const ModuleColumn(key: 'status', label: 'وضعیت'),
    ],
    summary: (rows) {
      final amount = rows.fold<double>(0, (s, r) => s + toNum(r['amount']));
      final balance = rows.fold<double>(0, (s, r) => s + toNum(r['amount']) - toNum(r['received']));
      return [
        SummaryItem(label: 'جمع مطالبات', value: fmtMoney(amount)),
        SummaryItem(label: 'مانده کل', value: fmtMoney(balance)),
      ];
    },
  ),

  'settingsServices': ModuleDef(
    key: 'settingsServices',
    title: 'خدمات و قیمت‌ها',
    addLabel: 'خدمت جدید',
    noMonthFilter: true,
    fields: const [
      ModuleField(key: 'name', label: 'نام آیتم / خدمت', type: FieldType.text, required: true),
      ModuleField(key: 'income', label: 'مبلغ پیش‌فرض دریافتی', type: FieldType.money),
      ModuleField(key: 'cost', label: 'هزینه پیش‌فرض مصرفی', type: FieldType.money),
      ModuleField(key: 'defaultPercent', label: 'درصد پیش‌فرض سهم سوپروایزر', type: FieldType.percent),
      ModuleField(key: 'active', label: 'فعال باشد؟', type: FieldType.boolean, options: ['بله', 'خیر']),
    ],
    columns: [
      const ModuleColumn(key: 'name', label: 'نام خدمت'),
      ModuleColumn(key: 'income', label: 'دریافتی پیش‌فرض', calc: (r) => fmtMoney(r['income'])),
      ModuleColumn(key: 'cost', label: 'هزینه پیش‌فرض', calc: (r) => fmtMoney(r['cost'])),
      ModuleColumn(
        key: 'active',
        label: 'فعال',
        calc: (r) => (r['active'] ?? true) ? 'فعال' : 'غیرفعال',
      ),
    ],
  ),

  'therapists': ModuleDef(
    key: 'therapists',
    title: 'درمانگران',
    addLabel: 'درمانگر جدید',
    noMonthFilter: true,
    fields: const [
      ModuleField(key: 'name', label: 'نام درمانگر', type: FieldType.text, required: true),
      ModuleField(key: 'percent', label: 'درصد سهم درمانگر', type: FieldType.percent),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: [
      const ModuleColumn(key: 'name', label: 'نام'),
      ModuleColumn(key: 'percent', label: 'درصد سهم', calc: (r) => fmtPercent(r['percent'])),
      const ModuleColumn(key: 'note', label: 'توضیحات'),
    ],
  ),

  'supervisors': ModuleDef(
    key: 'supervisors',
    title: 'سوپروایزرها',
    addLabel: 'سوپروایزر جدید',
    noMonthFilter: true,
    fields: const [
      ModuleField(key: 'name', label: 'نام سوپروایزر', type: FieldType.text, required: true),
      ModuleField(key: 'status', label: 'وضعیت', type: FieldType.select, options: ['فعال', 'غیرفعال']),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: const [
      ModuleColumn(key: 'name', label: 'نام'),
      ModuleColumn(key: 'status', label: 'وضعیت'),
      ModuleColumn(key: 'note', label: 'توضیحات'),
    ],
  ),

  'patients': ModuleDef(
    key: 'patients',
    title: 'پرونده بیماران',
    addLabel: 'بیمار جدید',
    fields: const [
      ModuleField(key: 'firstName', label: 'نام', type: FieldType.text, required: true),
      ModuleField(key: 'lastName', label: 'نام خانوادگی', type: FieldType.text, required: true),
      ModuleField(key: 'nationalCode', label: 'کد ملی', type: FieldType.text),
      ModuleField(key: 'birthDate', label: 'تاریخ تولد', type: FieldType.date, hint: 'به‌صورت شمسی'),
      ModuleField(key: 'gender', label: 'جنسیت', type: FieldType.select, options: ['مرد', 'زن']),
      ModuleField(key: 'mobile', label: 'شماره موبایل', type: FieldType.text),
      ModuleField(key: 'address', label: 'آدرس', type: FieldType.text),
      ModuleField(key: 'insurer', label: 'بیمه', type: FieldType.text),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: const [
      ModuleColumn(key: 'firstName', label: 'نام'),
      ModuleColumn(key: 'lastName', label: 'نام خانوادگی'),
      ModuleColumn(key: 'nationalCode', label: 'کد ملی'),
      ModuleColumn(key: 'mobile', label: 'موبایل'),
    ],
  ),

  'users': ModuleDef(
    key: 'users',
    title: 'کاربران و دسترسی‌ها',
    addLabel: 'کاربر جدید',
    noMonthFilter: true,
    fields: const [
      ModuleField(key: 'fullName', label: 'نام و نام خانوادگی', type: FieldType.text, required: true),
      ModuleField(key: 'username', label: 'نام کاربری', type: FieldType.text, required: true),
      ModuleField(key: 'password', label: 'رمز عبور', type: FieldType.password, required: true),
      ModuleField(
        key: 'role',
        label: 'سطح دسترسی',
        type: FieldType.select,
        options: ['مدیر سیستم', 'حسابدار', 'منشی/پذیرش', 'مشاهده‌گر'],
        required: true,
      ),
      ModuleField(key: 'active', label: 'وضعیت', type: FieldType.select, options: ['فعال', 'غیرفعال']),
      ModuleField(key: 'note', label: 'توضیحات', type: FieldType.text),
    ],
    columns: const [
      ModuleColumn(key: 'fullName', label: 'نام'),
      ModuleColumn(key: 'username', label: 'نام کاربری'),
      ModuleColumn(key: 'role', label: 'سطح دسترسی'),
      ModuleColumn(key: 'active', label: 'وضعیت'),
    ],
  ),
};

/// معادل NAV در main.py — گروه‌بندی منوی کناری
final List<NavGroup> navGroups = [
  const NavGroup('کلی', [
    NavItem('dashboard', 'داشبورد مدیریتی', 'chart-pie'),
    NavItem('payroll', 'فیش تسویه حساب', 'file-invoice'),
  ]),
  const NavGroup('بیماران', [
    NavItem('patients', 'پرونده بیماران', 'folder-user'),
  ]),
  const NavGroup('ثبت مراجعات و درآمد', [
    NavItem('services', 'ثبت خدمات', 'hospital'),
    NavItem('visits', 'ویزیت درمانگران', 'stethoscope'),
    NavItem('dental', 'دندانپزشکی', 'tooth'),
    NavItem('wechsler', 'تست وکسلر', 'note-sticky'),
    NavItem('insurance', 'بیمه', 'shield-heart'),
  ]),
  const NavGroup('مالی', [
    NavItem('expenses', 'هزینه‌ها', 'money-bill-transfer'),
    NavItem('receipts', 'دریافت‌ها', 'sack-dollar'),
    NavItem('bank', 'حساب‌ها و بانک', 'building-columns'),
    NavItem('creditors', 'بستانکاران', 'hand-holding-dollar'),
    NavItem('receivables', 'مطالبات بیماران', 'file-invoice-dollar'),
  ]),
  const NavGroup('تنظیمات پایه', [
    NavItem('settingsServices', 'خدمات و قیمت‌ها', 'gear'),
    NavItem('therapists', 'درمانگران', 'user-doctor'),
    NavItem('supervisors', 'سوپروایزرها', 'user-tie'),
    NavItem('users', 'کاربران و دسترسی‌ها', 'users-gear'),
  ]),
];

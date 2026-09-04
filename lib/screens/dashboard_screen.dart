import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../config/formatters.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockDataService>();
    final services = data.rows('services');
    final expenses = data.rows('expenses');
    final visits = data.rows('visits');

    final totalIncome = services.fold<double>(0, (s, r) => s + toNum(r['amount']));
    final totalExpense = expenses.fold<double>(0, (s, r) => s + toNum(r['amount']));
    final netIncome = totalIncome - totalExpense;
    final monthly = data.demoMonthlyIncome();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('داشبورد مدیریتی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('نمای کلی از وضعیت مالی این ماه', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.55,
                children: [
                  StatCard(
                    label: 'درآمد این ماه',
                    value: '${fmtMoney(totalIncome)} تومان',
                    icon: FontAwesomeIcons.sackDollar,
                    gradient: AppGradients.primary,
                    trend: 'از ${services.length} خدمت ثبت‌شده',
                  ),
                  StatCard(
                    label: 'هزینه‌های این ماه',
                    value: '${fmtMoney(totalExpense)} تومان',
                    icon: FontAwesomeIcons.receipt,
                    gradient: AppGradients.danger,
                  ),
                  StatCard(
                    label: 'سود خالص',
                    value: '${fmtMoney(netIncome)} تومان',
                    icon: FontAwesomeIcons.chartLine,
                    gradient: AppGradients.success,
                  ),
                  StatCard(
                    label: 'ویزیت‌های ثبت‌شده',
                    value: visits.length.toString(),
                    icon: FontAwesomeIcons.stethoscope,
                    gradient: AppGradients.warning,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('روند درآمد ۶ ماه اخیر',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                const labels = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور'];
                                final i = v.toInt();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(i < labels.length ? labels[i] : '',
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (int i = 0; i < monthly.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: monthly[i] / 1000000,
                                width: 26,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [AppColors.blueLight, AppColors.blue],
                                ),
                              ),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

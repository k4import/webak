import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:webak/features/statistics/presentation/screens/statistics_settings_screen.dart';

class StatisticsReportsScreen extends StatefulWidget {
  const StatisticsReportsScreen({super.key});

  @override
  State<StatisticsReportsScreen> createState() => _StatisticsReportsScreenState();
}

class _StatisticsReportsScreenState extends State<StatisticsReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // بيانات تجريبية للرسوم البيانية
  final List<double> weeklyTasksData = [5, 8, 12, 7, 9, 6, 10];
  final List<double> monthlyCompletionData = [65, 72, 58, 80, 95, 60, 75, 82, 70, 85, 90, 78];
  
  // بيانات تجريبية لتوزيع المهام حسب الحالة
  final Map<String, double> taskStatusData = {
    'مكتملة': 45,
    'قيد التنفيذ': 30,
    'متأخرة': 15,
    'ملغاة': 10,
  };
  
  // بيانات تجريبية لتوزيع المهام حسب الأولوية
  final Map<String, double> taskPriorityData = {
    'عالية': 25,
    'متوسطة': 45,
    'منخفضة': 30,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات الإحصائيات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatisticsSettingsScreen(),
                ),
              );
            },
          ),
        ],
        title: const Text('الإحصائيات والتقارير'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الإحصائيات'),
            Tab(text: 'التقارير'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ملخص المهام'),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('المهام الأسبوعية'),
          _buildWeeklyTasksChart(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('معدل إكمال المهام الشهري'),
          _buildMonthlyCompletionChart(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('توزيع المهام'),
          _buildDistributionCharts(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportCard(
            'تقرير المهام الأسبوعي',
            'ملخص لجميع المهام والإنجازات خلال الأسبوع الحالي',
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          
          _buildReportCard(
            'تقرير المهام الشهري',
            'تحليل مفصل لأداء المهام خلال الشهر الحالي',
            Icons.insert_chart,
          ),
          const SizedBox(height: 16),
          
          _buildReportCard(
            'تقرير الإنتاجية',
            'تحليل لمعدل إنتاجيتك ومقارنته بالفترات السابقة',
            Icons.trending_up,
          ),
          const SizedBox(height: 16),
          
          _buildReportCard(
            'تقرير المهام المتأخرة',
            'قائمة بالمهام المتأخرة وتحليل لأسباب التأخير',
            Icons.warning,
          ),
          const SizedBox(height: 16),
          
          _buildCustomReportSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard('إجمالي المهام', '125', Icons.assignment),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard('المهام المكتملة', '78', Icons.check_circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard('المهام المتأخرة', '12', Icons.warning),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTasksChart() {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 15,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          titles[value.toInt() % titles.length],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value % 5 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: weeklyTasksData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: AppTheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCompletionChart() {
    return SizedBox(
      height: 200,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
                      if (value.toInt() % 3 == 0 && value.toInt() < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: monthlyCompletionData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionCharts() {
    return Row(
      children: [
        Expanded(
          child: _buildPieChart('حالة المهام', taskStatusData, 180),
        ),
        Expanded(
          child: _buildPieChart('أولوية المهام', taskPriorityData, 180),
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, Map<String, double> data, double height) {
    final List<Color> colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.warning,
      AppTheme.error,
      Colors.purple,
    ];

    return SizedBox(
      height: height,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: data.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: item.value,
                        title: '${item.value.toInt()}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: data.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[index % colors.length],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.key,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            _showReportGenerationDialog(title);
          },
          child: const Text('إنشاء'),
        ),
      ),
    );
  }

  Widget _buildCustomReportSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إنشاء تقرير مخصص',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('الفترة الزمنية:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('من'),
                    onPressed: () {
                      // اختيار تاريخ البداية
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('إلى'),
                    onPressed: () {
                      // اختيار تاريخ النهاية
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('نوع التقرير:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              value: 'ملخص المهام',
              items: const [
                DropdownMenuItem(value: 'ملخص المهام', child: Text('ملخص المهام')),
                DropdownMenuItem(value: 'تقرير الإنتاجية', child: Text('تقرير الإنتاجية')),
                DropdownMenuItem(value: 'تقرير المهام المتأخرة', child: Text('تقرير المهام المتأخرة')),
                DropdownMenuItem(value: 'تقرير مفصل', child: Text('تقرير مفصل')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                icon: const Icon(Icons.file_download),
                label: const Text('إنشاء التقرير'),
                onPressed: () {
                  _showReportGenerationDialog('تقرير مخصص');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportGenerationDialog(String reportTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إنشاء $reportTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('جاري إنشاء التقرير...'),
          ],
        ),
      ),
    );

    // محاكاة عملية إنشاء التقرير
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showReportReadyDialog(reportTitle);
    });
  }

  void _showReportReadyDialog(String reportTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إنشاء التقرير'),
        content: Text('تم إنشاء $reportTitle بنجاح.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تنزيل التقرير بنجاح'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('تنزيل'),
          ),
        ],
      ),
    );
  }
}
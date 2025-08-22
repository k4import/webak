import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/shared/widgets/widgets.dart';

class PersonalStatisticsScreen extends StatefulWidget {
  const PersonalStatisticsScreen({super.key});

  @override
  State<PersonalStatisticsScreen> createState() => _PersonalStatisticsScreenState();
}

class _PersonalStatisticsScreenState extends State<PersonalStatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Get current user
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _user = authState.user;
    }

    // Load tasks
    await context.read<TaskCubit>().loadTasks();
    _tasks = context.read<TaskCubit>().tasks;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات الشخصية'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الإحصائيات'),
            Tab(text: 'الإنجازات'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }

  Widget _buildStatisticsTab() {
    // Calculate statistics
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task.status == 'completed').length;
    final inProgressTasks = _tasks.where((task) => task.status == 'in_progress').length;
    final pendingTasks = _tasks.where((task) => task.status == 'pending').length;
    
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(1) : '0';
    
    // Group tasks by date for the activity chart
    final Map<DateTime, int> tasksByDate = {};
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    
    // Initialize all dates in the last 30 days with 0 tasks
    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      tasksByDate[DateTime(date.year, date.month, date.day)] = 0;
    }
    
    // Count tasks by creation date
    for (final task in _tasks) {
      if (task.createdAt != null && task.createdAt!.isAfter(startDate)) {
        final date = DateTime(task.createdAt!.year, task.createdAt!.month, task.createdAt!.day);
        tasksByDate[date] = (tasksByDate[date] ?? 0) + 1;
      }
    }
    
    // Sort dates for the chart
    final sortedDates = tasksByDate.keys.toList()..sort((a, b) => a.compareTo(b));
    final activityData = sortedDates.map((date) => tasksByDate[date] ?? 0).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، ${_user?.fullName ?? _user?.username ?? "مستخدم"}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.md),
          
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المهام',
                  totalTasks.toString(),
                  Icons.task,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: _buildStatCard(
                  'نسبة الإنجاز',
                  '$completionRate%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'قيد التنفيذ',
                  inProgressTasks.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: _buildStatCard(
                  'قيد الانتظار',
                  pendingTasks.toString(),
                  Icons.hourglass_empty,
                  Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.lg),
          Text(
            'توزيع المهام',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.md),
          SizedBox(
            height: 200,
            child: totalTasks > 0
                ? PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: completedTasks.toDouble(),
                          title: 'مكتملة',
                          color: Colors.green,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: inProgressTasks.toDouble(),
                          title: 'قيد التنفيذ',
                          color: Colors.orange,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: pendingTasks.toDouble(),
                          title: 'قيد الانتظار',
                          color: Colors.red,
                          radius: 60,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      startDegreeOffset: 180,
                    ),
                  )
                : const Center(child: Text('لا توجد بيانات كافية')),
          ),
          
          const SizedBox(height: AppTheme.lg),
          Text(
            'نشاط المهام (آخر 30 يوم)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.md),
          SizedBox(
            height: 200,
            child: activityData.isNotEmpty
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            activityData.length,
                            (index) => FlSpot(index.toDouble(), activityData[index].toDouble()),
                          ),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primary.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('لا توجد بيانات كافية')),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    // Define achievements based on user's task history
    final achievements = [
      {
        'title': 'البداية الموفقة',
        'description': 'أكمل أول مهمة',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': _tasks.any((task) => task.status == 'completed'),
      },
      {
        'title': 'منجز نشط',
        'description': 'أكمل 10 مهام',
        'icon': Icons.workspace_premium,
        'color': Colors.amber,
        'unlocked': _tasks.where((task) => task.status == 'completed').length >= 10,
      },
      {
        'title': 'خبير المهام',
        'description': 'أكمل 50 مهمة',
        'icon': Icons.military_tech,
        'color': Colors.amber,
        'unlocked': _tasks.where((task) => task.status == 'completed').length >= 50,
      },
      {
        'title': 'متابع يومي',
        'description': 'استخدم التطبيق لمدة 7 أيام متتالية',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'unlocked': false, // Would need login history to implement
      },
      {
        'title': 'منظم محترف',
        'description': 'أنشئ 5 فئات مختلفة للمهام',
        'icon': Icons.category,
        'color': Colors.purple,
        'unlocked': false, // Would need categories data to implement
      },
      {
        'title': 'سريع الاستجابة',
        'description': 'أكمل 5 مهام قبل الموعد النهائي',
        'icon': Icons.speed,
        'color': Colors.green,
        'unlocked': false, // Would need deadline data to implement
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.md),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool unlocked = achievement['unlocked'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.md),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: unlocked
                  ? achievement['color'] as Color
                  : Colors.grey.shade300,
              child: Icon(
                achievement['icon'] as IconData,
                color: unlocked ? Colors.white : Colors.grey,
              ),
            ),
            title: Text(
              achievement['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            subtitle: Text(achievement['description'] as String),
            trailing: unlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppTheme.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
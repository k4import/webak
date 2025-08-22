import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/core/utils/responsive_utils.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/auth/presentation/screens/login_screen.dart';
import 'package:webak/features/auth/presentation/screens/profile_screen.dart';
import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/presentation/cubit/report_cubit.dart';

import 'package:webak/features/reports/presentation/screens/report_detail_screen.dart';
import 'package:webak/features/settings/presentation/screens/settings_screen.dart';
import 'package:webak/features/statistics/presentation/screens/statistics_reports_screen.dart';
import 'package:webak/features/statistics/presentation/screens/personal_statistics_screen.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/features/tasks/presentation/screens/admin_add_task_screen.dart';
import 'package:webak/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:webak/features/tasks/presentation/screens/task_advanced_settings_screen.dart';
import 'package:webak/shared/widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TasksTab(),
    const ReportsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppNavBar(
            title: 'لوحة التحكم',
            actions: [
              if (state is AuthAuthenticated && state.user.role == 'manager')
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAddTaskScreen(),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Show search dialog
                },
              ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'المهام',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'التقارير',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        );
      },
    );
  }
}

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> with SingleTickerProviderStateMixin {
  String _currentFilter = 'all';
  String _currentEisenhowerFilter = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _loadTasks() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user.role == 'manager') {
      context.read<TaskCubit>().loadAllTasks();
    } else {
      context.read<TaskCubit>().loadTasks();
    }
  }
  
  void _filterByStatus(String status) {
    setState(() {
      _currentFilter = status;
      _currentEisenhowerFilter = '';
    });
    context.read<TaskCubit>().loadTasksByStatus(status);
  }
  
  void _filterByEisenhower(String filter) {
    setState(() {
      _currentEisenhowerFilter = filter;
      _currentFilter = 'all';
    });
    
    _loadTasks();
    
    // Animate the list refresh
    _animationController.reset();
    _animationController.forward();
  }
  
  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    if (_currentEisenhowerFilter.isEmpty) {
      return tasks;
    }
    
    switch (_currentEisenhowerFilter) {
      case 'urgent_important':
        return tasks.where((task) => task.isUrgent && task.isImportant).toList();
      case 'important':
        return tasks.where((task) => task.isImportant && !task.isUrgent).toList();
      case 'urgent':
        return tasks.where((task) => task.isUrgent && !task.isImportant).toList();
      case 'other':
        return tasks.where((task) => !task.isUrgent && !task.isImportant).toList();
      default:
        return tasks;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          AppUtils.showSnackBar(
            context: context,
            message: state.message,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state is TaskLoading && context.read<TaskCubit>().tasks.isEmpty) {
          return const Center(
            child: AppLoader(message: 'جاري تحميل المهام...'),
          );
        }
        
        final allTasks = context.read<TaskCubit>().tasks;
        final tasks = _getFilteredTasks(allTasks);
        
        if (tasks.isEmpty) {
          return Center(
            child: EmptyTaskList(
              message: 'لا توجد مهام حالياً',
              buttonText: 'إضافة مهمة جديدة',
              onButtonPressed: () {
                _navigateToTaskDetail(context);
              },
            ),
          );
        }
        
        return ResponsiveUtils.buildResponsiveContainer(
          context: context,
          child: Column(
            children: [
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المهام',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'إعدادات المهام المتقدمة',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskAdvancedSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            _buildFilterChips(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // استخدام forceRefresh عند السحب للتحديث
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated && authState.user.role == 'manager') {
                    context.read<TaskCubit>().loadAllTasks(forceRefresh: true);
                  } else {
                    context.read<TaskCubit>().loadTasks(forceRefresh: true);
                  }
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ResponsiveWidget(
                      mobile: ListView.builder(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final itemAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                index / (tasks.length > 0 ? tasks.length : 1) * 0.5,
                                (index + 1) / (tasks.length > 0 ? tasks.length : 1) * 0.5 + 0.5,
                                curve: Curves.easeOut,
                              ),
                            ),
                          );
                          
                          return FadeTransition(
                            opacity: itemAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.5, 0),
                                end: Offset.zero,
                              ).animate(itemAnimation),
                              child: _buildTaskCard(context, task),
                            ),
                          );
                        },
                      ),
                      tablet: GridView.builder(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
                          crossAxisSpacing: AppTheme.md,
                          mainAxisSpacing: AppTheme.md,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final itemAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                index / (tasks.length > 0 ? tasks.length : 1) * 0.5,
                                (index + 1) / (tasks.length > 0 ? tasks.length : 1) * 0.5 + 0.5,
                                curve: Curves.easeOut,
                              ),
                            ),
                          );
                          
                          return FadeTransition(
                            opacity: itemAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.5, 0),
                                end: Offset.zero,
                              ).animate(itemAnimation),
                              child: _buildTaskCard(context, task),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterChips() {
    return Column(
      children: [
        // Status filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.md,
            vertical: AppTheme.sm,
          ),
          child: Row(
            children: [
              _buildFilterChip('all', 'الكل'),
              const SizedBox(width: AppTheme.sm),
              _buildFilterChip('pending', 'قيد الانتظار'),
              const SizedBox(width: AppTheme.sm),
              _buildFilterChip('in_progress', 'قيد التنفيذ'),
              const SizedBox(width: AppTheme.sm),
              _buildFilterChip('completed', 'مكتملة'),
            ],
          ),
        ),
        
        // Eisenhower Matrix filters
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.md,
            vertical: AppTheme.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildEisenhowerButton(
                  title: 'عاجل ومهم',
                  color: Colors.red.shade400,
                  icon: Icons.priority_high,
                  onTap: () => _filterByEisenhower('urgent_important'),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: _buildEisenhowerButton(
                  title: 'مهم',
                  color: Colors.blue.shade400,
                  icon: Icons.star,
                  onTap: () => _filterByEisenhower('important'),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: _buildEisenhowerButton(
                  title: 'عاجل',
                  color: Colors.amber.shade400,
                  icon: Icons.timer,
                  onTap: () => _filterByEisenhower('urgent'),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: _buildEisenhowerButton(
                  title: 'أخرى',
                  color: Colors.green.shade400,
                  icon: Icons.check_circle_outline,
                  onTap: () => _filterByEisenhower('other'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _currentFilter == value && _currentEisenhowerFilter.isEmpty;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (value == 'all') {
          _loadTasks();
        } else {
          _filterByStatus(value);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary.withOpacity(0.2),
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
  
  Widget _buildEisenhowerButton({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentEisenhowerFilter == title.toLowerCase().replaceAll(' ', '_');
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.md),
      child: InkWell(
        onTap: () => _navigateToTaskDetail(context, task: task),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: task.isUrgent 
                ? Colors.red.withOpacity(0.3) 
                : Colors.transparent,
              width: task.isUrgent ? 2 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with priority and status
              Container(
                decoration: BoxDecoration(
                  color: task.getPriorityColor().withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadius),
                    topRight: Radius.circular(AppTheme.borderRadius),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.md,
                  vertical: AppTheme.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            task.getStatusIcon(),
                            color: task.getPriorityColor(),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (task.isUrgent)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.timer,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        if (task.isImportant)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        AppStatusBadge(status: task.status, small: true),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppTheme.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    // Details row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location
                        if (task.location != null)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    task.location!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Time
                        if (task.startTime != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.getFormattedStartTime(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToTaskDetail(BuildContext context, {TaskModel? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    ).then((_) => _loadTasks());
  }
}

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }
  
  void _loadReports() {
    context.read<ReportCubit>().loadReports();
  }
  
  void _filterByType(String type) {
    setState(() {
      _currentFilter = type;
    });
    context.read<ReportCubit>().loadReportsByType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقارير',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsReportsScreen(),
                    ),
                  ).then((_) => _loadReports());
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('الإحصائيات والتقارير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          _buildFilterChips(),
          const SizedBox(height: AppTheme.md),
          Expanded(
            child: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportLoaded) {
                  return _buildReportsList(state.reports);
                } else if (state is ReportError) {
                  return Center(child: Text(state.message));
                } else {
                  return _buildReportsList([]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'الكل'),
          const SizedBox(width: AppTheme.sm),
          _buildFilterChip('daily', 'يومي'),
          const SizedBox(width: AppTheme.sm),
          _buildFilterChip('weekly', 'أسبوعي'),
          const SizedBox(width: AppTheme.sm),
          _buildFilterChip('monthly', 'شهري'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _currentFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (value == 'all') {
          _loadReports();
        } else {
          _filterByType(value);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary.withOpacity(0.2),
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildReportsList(List<ReportModel> reports) {
    if (reports.isEmpty) {
      return const Center(
        child: Text('لا توجد تقارير متاحة'),
      );
    }
    
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final createdDate = report.createdAt ?? DateTime.now();
        final daysAgo = DateTime.now().difference(createdDate).inDays;
        
        String dateText;
        if (daysAgo == 0) {
          dateText = 'اليوم';
        } else if (daysAgo == 1) {
          dateText = 'منذ يوم';
        } else if (daysAgo < 7) {
          dateText = 'منذ $daysAgo أيام';
        } else if (daysAgo < 30) {
          final weeks = (daysAgo / 7).floor();
          dateText = 'منذ $weeks أسابيع';
        } else {
          final months = (daysAgo / 30).floor();
          dateText = 'منذ $months أشهر';
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.md),
          child: ListTile(
            title: Text(report.title),
            subtitle: Text(report.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                _buildReportTypeBadge(report.type),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(report: report),
                ),
              ).then((_) => _loadReports());
            },
          ),
        );
      },
    );
  }
  
  Widget _buildReportTypeBadge(String type) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    
    switch (type) {
      case 'daily':
        badgeColor = Colors.green;
        badgeIcon = Icons.today;
        badgeText = 'يومي';
        break;
      case 'weekly':
        badgeColor = Colors.blue;
        badgeIcon = Icons.calendar_view_week;
        badgeText = 'أسبوعي';
        break;
      case 'monthly':
        badgeColor = Colors.purple;
        badgeIcon = Icons.calendar_month;
        badgeText = 'شهري';
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.description;
        badgeText = 'آخر';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 30),
                        )
                      : null,
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  user.fullName ?? user.username ?? 'مستخدم',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppTheme.xl),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings, color: AppTheme.primary),
                    title: const Text('الإعدادات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: AppTheme.primary),
                    title: const Text('الملف الشخصي'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart, color: AppTheme.primary),
                    title: const Text('الإحصائيات الشخصية'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalStatisticsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                // Admin logout button with special styling
                if (user.role == 'admin') ...[
                  Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                      title: const Text('تسجيل خروج المدير', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('خروج آمن من حساب المدير'),
                      trailing: const Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.red),
                                SizedBox(width: 8),
                                Text('تسجيل خروج المدير'),
                              ],
                            ),
                            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حساب المدير؟\nسيتم إنهاء جلسة العمل الحالية.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthCubit>().logout();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('تسجيل خروج المدير'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Regular user logout button
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('تسجيل الخروج'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تسجيل الخروج'),
                            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthCubit>().logout();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
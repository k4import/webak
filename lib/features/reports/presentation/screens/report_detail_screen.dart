import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/features/reports/domain/models/report_model.dart';
import 'package:webak/features/reports/presentation/cubit/report_cubit.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/shared/widgets/widgets.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel? report;
  
  const ReportDetailScreen({super.key, this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  String _reportType = 'weekly';
  List<String> _selectedTaskIds = [];

  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    if (widget.report != null) {
      // Load tasks included in this report
      _loadIncludedTasks();
    } else {
      // Load all tasks for selection
      _loadAllTasks();
    }
  }
  
  void _initializeControllers() {
    final report = widget.report;
    _titleController = TextEditingController(text: report?.title ?? '');
    _descriptionController = TextEditingController(text: report?.description ?? '');
    _startDate = report?.startDate ?? DateTime.now();
    _endDate = report?.endDate ?? DateTime.now().add(const Duration(days: 7));
    _reportType = report?.type ?? 'weekly';
    _selectedTaskIds = report?.taskIds?.toList() ?? [];
  }
  
  void _loadIncludedTasks() {
    // TODO: Load tasks by IDs
    // context.read<TaskCubit>().loadTasksByIds(widget.report!.taskIds ?? []);
  }
  
  void _loadAllTasks() {
    context.read<TaskCubit>().loadTasks();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.report != null;
    
    return BlocListener<ReportCubit, ReportState>(
      listener: (context, state) {
        if (state is ReportCreated || state is ReportUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'تم تحديث التقرير' : 'تم إنشاء التقرير')),
          );
          Navigator.pop(context);
        } else if (state is ReportDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف التقرير')),
          );
          Navigator.pop(context);
        } else if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'تفاصيل التقرير' : 'تقرير جديد'),

        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportForm(),
                const SizedBox(height: AppTheme.lg),
                _buildDateRangeSection(),
                const SizedBox(height: AppTheme.lg),
                _buildReportTypeSection(),
                const SizedBox(height: AppTheme.lg),
                _buildTasksSection(),
                
                const SizedBox(height: AppTheme.xl),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isEditing)
                  TextButton(
                    onPressed: _confirmDelete,
                    child: const Text('حذف'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveReport,
                  child: Text(isEditing ? 'تحديث' : 'إنشاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildReportForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان التقرير',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال عنوان للتقرير';
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.md),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'وصف التقرير',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال وصف للتقرير';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildDateRangeSection() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفترة الزمنية',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.sm),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ البداية',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_startDate)),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.md),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ النهاية',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_endDate)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          // Ensure start date is not after end date
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }
  
  Widget _buildReportTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع التقرير',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.sm),
        DropdownButtonFormField<String>(
          value: _reportType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('يومي')),
            DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
            DropdownMenuItem(value: 'monthly', child: Text('شهري')),
            DropdownMenuItem(value: 'custom', child: Text('مخصص')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _reportType = value;
                
                // Adjust date range based on report type
                final now = DateTime.now();
                switch (value) {
                  case 'daily':
                    _startDate = DateTime(now.year, now.month, now.day);
                    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                    break;
                  case 'weekly':
                    // Start from the beginning of the week (Sunday)
                    final daysToSubtract = now.weekday % 7;
                    _startDate = DateTime(now.year, now.month, now.day - daysToSubtract);
                    _endDate = _startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
                    break;
                  case 'monthly':
                    _startDate = DateTime(now.year, now.month, 1);
                    _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                    break;
                  case 'custom':
                    // Keep current selection
                    break;
                }
              });
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المهام المضمنة',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.sm),
        BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              final tasks = state.tasks;
              if (tasks.isEmpty) {
                return const Center(
                  child: Text('لا توجد مهام متاحة للتضمين في التقرير'),
                );
              }
              
              return _buildTaskSelectionList(tasks);
            } else {
              return const Center(
                child: Text('حدث خطأ أثناء تحميل المهام'),
              );
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildTaskSelectionList(List<TaskModel> tasks) {
    // Filter tasks within the selected date range
    final filteredTasks = tasks.where((task) {
      final taskDate = task.dueDate ?? DateTime.now();
      return taskDate.isAfter(_startDate) && taskDate.isBefore(_endDate);
    }).toList();
    
    if (filteredTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.md),
        child: Center(
          child: Text('لا توجد مهام في الفترة الزمنية المحددة'),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 200,
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          final isSelected = _selectedTaskIds.contains(task.id);
          
          return CheckboxListTile(
            title: Text(task.title),
            subtitle: Text(
              task.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedTaskIds.add(task.id!);
                } else {
                  _selectedTaskIds.remove(task.id);
                }
              });
            },
            secondary: task.priority != null
                ? AppPriorityBadge(priority: task.priority!, small: true)
                : null,
          );
        },
      ),
    );
  }
  

  

  
  void _saveReport() {
    if (_formKey.currentState?.validate() != true) return;
    
    if (_selectedTaskIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار مهمة واحدة على الأقل')),
      );
      return;
    }
    
    final report = ReportModel(
      id: widget.report?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _reportType,
      startDate: _startDate,
      endDate: _endDate,

      createdAt: widget.report?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: widget.report?.userId,
      taskIds: _selectedTaskIds,
    );
    
    if (widget.report != null) {
      context.read<ReportCubit>().updateReport(report);
    } else {
      context.read<ReportCubit>().createReport(report);
    }
  }
  
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التقرير'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا التقرير؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport();
            },
            child: const Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
  
  void _deleteReport() {
    if (widget.report?.id == null) return;
    
    context.read<ReportCubit>().deleteReport(widget.report!.id!);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/shared/widgets/widgets.dart';

class AdminAddTaskScreen extends StatefulWidget {
  const AdminAddTaskScreen({super.key});

  @override
  State<AdminAddTaskScreen> createState() => _AdminAddTaskScreenState();
}

class _AdminAddTaskScreenState extends State<AdminAddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  String _selectedStatus = 'pending';
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = TaskModel(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
        status: _selectedStatus,
        dueDate: _dueDate,
      );
      context.read<TaskCubit>().createTask(task);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: 'إضافة مهمة جديدة'),
      body: BlocListener<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskCreated) {
            AppUtils.showSnackBar(context: context, message: 'تم إضافة المهمة بنجاح');
          } else if (state is TaskError) {
            AppUtils.showSnackBar(context: context, message: state.message, isError: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppTextField(
                  label: 'العنوان',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  validator: (value) => value?.isEmpty ?? true ? 'الرجاء إدخال العنوان' : null,
                ),
                const SizedBox(height: AppTheme.md),
                AppTextField(
                  label: 'الوصف',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'الرجاء إدخال الوصف' : null,
                ),
                const SizedBox(height: AppTheme.md),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'الأولوية',
                    prefixIcon: Icon(Icons.priority_high),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                    DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                    DropdownMenuItem(value: 'high', child: Text('عالية')),
                  ],
                  onChanged: (value) => setState(() => _selectedPriority = value!),
                ),
                const SizedBox(height: AppTheme.md),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                    DropdownMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: AppTheme.md),
                ListTile(
                  title: Text(_dueDate == null ? 'تاريخ الاستحقاق' : AppUtils.formatDate(_dueDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDueDate,
                ),
                const SizedBox(height: AppTheme.xl),
                AppButton(
                  text: 'إضافة المهمة',
                  onPressed: _addTask,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
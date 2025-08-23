import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/shared/widgets/widgets.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _status = 'pending';
  String _priority = 'medium';
  DateTime? _dueDate;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _location;
  List<String> _tags = [];
  bool _isUrgent = false;
  bool _isImportant = false;
  Map<String, dynamic> _formData = {};
  
  // Form data controllers
  final _pestTypeController = TextEditingController();
  final _treatmentMethodController = TextEditingController();
  final _chemicalsUsedController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _startTime = widget.task!.startTime;
      _endTime = widget.task!.endTime;
      _location = widget.task!.location;
      _locationController.text = _location ?? '';
      _tags = List.from(widget.task!.tags ?? []);
      _isUrgent = widget.task!.isUrgent ?? false;
      _isImportant = widget.task!.isImportant ?? false;
      _formData = Map.from(widget.task!.formData ?? {});
      
      // Initialize form data controllers
      _pestTypeController.text = _formData['pest_type'] ?? '';
      _treatmentMethodController.text = _formData['treatment_method'] ?? '';
      _chemicalsUsedController.text = _formData['chemicals_used'] ?? '';
      _notesController.text = _formData['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _pestTypeController.dispose();
    _treatmentMethodController.dispose();
    _chemicalsUsedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // جمع بيانات النموذج
      _formData = {
        'pest_type': _pestTypeController.text,
        'treatment_method': _treatmentMethodController.text,
        'chemicals_used': _chemicalsUsedController.text,
        'notes': _notesController.text,
      };
      
      final task = TaskModel(
        id: _isEditing ? widget.task!.id : null,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? '' : _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        tags: _tags.isEmpty ? null : _tags,
        createdAt: _isEditing ? widget.task!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        formData: _formData,
        isUrgent: _isUrgent,
        isImportant: _isImportant,
      );

      if (_isEditing) {
        context.read<TaskCubit>().updateTask(task);
      } else {
        context.read<TaskCubit>().createTask(task);
      }
    }
  }

  void _completeTask() async {
    if (_formKey.currentState!.validate()) {
      // التحقق من البيانات المطلوبة
      if (!_validateRequiredFields()) {
        return;
      }
      
      // جمع بيانات النموذج
      _formData = {
        'pest_type': _pestTypeController.text,
        'treatment_method': _treatmentMethodController.text,
        'chemicals_used': _chemicalsUsedController.text,
        'notes': _notesController.text,
      };
      
      // عرض popup التأكيد
      final confirmed = await _showCompletionConfirmationDialog();
      if (!confirmed) return;
      
      final task = TaskModel(
        id: widget.task!.id,
        title: widget.task!.title,
        description: widget.task!.description,
        status: 'completed', // تغيير الحالة إلى مكتملة
        priority: widget.task!.priority,
        dueDate: widget.task!.dueDate,
        startTime: widget.task!.startTime,
        endTime: widget.task!.endTime,
        location: widget.task!.location,
        tags: widget.task!.tags,
        createdAt: widget.task!.createdAt,
        updatedAt: DateTime.now(),
        formData: _formData,
        isUrgent: widget.task!.isUrgent,
        isImportant: widget.task!.isImportant,
        userId: widget.task!.userId,
        assignedTo: widget.task!.assignedTo,
      );

      context.read<TaskCubit>().updateTask(task);
    }
  }

  bool _validateRequiredFields() {
    List<String> missingFields = [];
    
    if (_pestTypeController.text.trim().isEmpty) {
      missingFields.add('نوع الآفة');
    }
    if (_treatmentMethodController.text.trim().isEmpty) {
      missingFields.add('طريقة العلاج');
    }
    if (_chemicalsUsedController.text.trim().isEmpty) {
      missingFields.add('المواد المستخدمة');
    }
    if (_notesController.text.trim().isEmpty) {
      missingFields.add('الملاحظات');
    }
    
    if (missingFields.isNotEmpty) {
      AppUtils.showSnackBar(
        context: context,
        message: 'يرجى ملء الحقول المطلوبة: ${missingFields.join(', ')}',
        isError: true,
      );
      return false;
    }
    
    return true;
  }

  Future<bool> _showCompletionConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد إنهاء المهمة'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'يرجى مراجعة البيانات المدخلة قبل إنهاء المهمة:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildConfirmationField('نوع الآفة', _pestTypeController.text),
                _buildConfirmationField('طريقة العلاج', _treatmentMethodController.text),
                _buildConfirmationField('المواد المستخدمة', _chemicalsUsedController.text),
                _buildConfirmationField('الملاحظات', _notesController.text),
                const SizedBox(height: 16),
                const Text(
                  'هل أنت متأكد من إنهاء هذه المهمة؟',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'تأكيد الإنهاء',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildConfirmationField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                fontStyle: value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTask() async {
    if (_isEditing) {
      final confirmed = await AppUtils.showConfirmationDialog(
        context,
        'حذف المهمة',
        'هل أنت متأكد من حذف هذه المهمة؟',
      );
      if (confirmed && mounted) {
        context.read<TaskCubit>().deleteTask(widget.task!.id!);
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // في build method - تحديث منطق isEditable:
        final user = authState is AuthAuthenticated ? authState.user : null;
        final isAdmin = user?.role == 'admin';
        final isEmployee = user?.role == 'employee';
        
        // المدير: يمكنه إنشاء وتعديل جميع المهام
        // الموظف: يمكنه عرض وإنهاء المهام المعينة له
        final isEditable = isAdmin || (isEmployee && _isEditing && (widget.task?.assignedTo == user?.id || widget.task?.userId == user?.id));
        
        // للموظف: يمكنه فقط تعديل بيانات النموذج وإنهاء المهمة
        final canEditFields = isAdmin;
        
        return Scaffold(
          appBar: AppNavBar(
            title: _isEditing ? 'تفاصيل المهمة' : 'مهمة جديدة',
            actions: _isEditing && user?.role == 'admin'
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteTask,
                    ),
                  ]
                : null,
          ),
          body: BlocListener<TaskCubit, TaskState>(
            listener: (context, state) {
              if (state is TaskError) {
                AppUtils.showSnackBar(context: context, message: state.message, isError: true);
              } else if (state is TaskCreated) {
                AppUtils.showSnackBar(context: context, message: 'تم إنشاء المهمة بنجاح');
                Navigator.of(context).pop();
              } else if (state is TaskUpdated) {
                AppUtils.showSnackBar(context: context, message: 'تم تحديث المهمة بنجاح');
                Navigator.of(context).pop();
              }
            },
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.md),
                  children: [
                    // Title
                    if (canEditFields)
                      AppTextField(
                        controller: _titleController,
                        label: 'عنوان المهمة',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال عنوان المهمة';
                          }
                          return null;
                        },
                      )
                    else
                      ListTile(
                        title: const Text('عنوان المهمة'),
                        subtitle: Text(widget.task?.title ?? ''),
                        contentPadding: EdgeInsets.zero,
                      ),
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Description
                    if (canEditFields)
                      AppTextField(
                        controller: _descriptionController,
                        label: 'وصف المهمة',
                        maxLines: 3,
                      )
                    else
                      ListTile(
                        title: const Text('وصف المهمة'),
                        subtitle: Text(widget.task?.description ?? 'لا يوجد وصف'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Status - للموظف: للقراءة فقط
                    _buildDropdown(
                      isEditable: canEditFields,
                      label: 'حالة المهمة',
                      value: _status,
                      items: [
                        const DropdownMenuItem(value: 'pending', child: Text('معلقة')),
                        const DropdownMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
                        const DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                      ],
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Priority - للموظف: للقراءة فقط
                    _buildDropdown(
                      isEditable: canEditFields,
                      label: 'أولوية المهمة',
                      value: _priority,
                      items: [
                        const DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                        const DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                        const DropdownMenuItem(value: 'high', child: Text('عالية')),
                      ],
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Due Date
                    ListTile(
                      title: const Text('تاريخ الاستحقاق'),
                      subtitle: Text(_dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : 'لم يتم تحديد تاريخ'),
                      trailing: isEditable
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _dueDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() => _dueDate = date);
                                    }
                                  },
                                ),
                                if (_dueDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() => _dueDate = null),
                                  ),
                              ],
                            )
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Location
                    if (isEditable)
                      AppTextField(
                        controller: _locationController,
                        label: 'الموقع',
                        prefixIcon: Icons.location_on,
                      )
                    else
                      ListTile(
                        title: const Text('الموقع'),
                        subtitle: Text(_location ?? 'لم يتم تحديد موقع'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                    const SizedBox(height: AppTheme.md),
                    
                    // Eisenhower Matrix
                    if (isEditable) ...[  
                      _buildSectionHeader(context, 'مصفوفة آيزنهاور'),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('عاجل'),
                              value: _isUrgent,
                              activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  _isUrgent = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('مهم'),
                              value: _isImportant,
                              activeColor: Colors.amber,
                              onChanged: (value) {
                                setState(() {
                                  _isImportant = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[  
                      ListTile(
                        title: const Text('التصنيف'),
                        subtitle: Text(_getEisenhowerClassification()),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Start and End Time
                    if (isEditable) ...[  
                      _buildSectionHeader(context, 'وقت المهمة'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePicker(
                              label: 'وقت البدء',
                              time: _startTime,
                              onSelect: (time) {
                                setState(() => _startTime = time);
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          Expanded(
                            child: _buildTimePicker(
                              label: 'وقت الانتهاء',
                              time: _endTime,
                              onSelect: (time) {
                                setState(() => _endTime = time);
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (_startTime != null || _endTime != null) ...[  
                      ListTile(
                        title: const Text('وقت المهمة'),
                        subtitle: Text(_getTimeRangeText()),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Form Data
                    if (isEditable) ...[  
                      _buildSectionHeader(context, 'بيانات نموذج المكافحة'),
                      AppTextField(
                        controller: _pestTypeController,
                        label: 'نوع الآفة',
                        prefixIcon: Icons.bug_report,
                      ),
                      const SizedBox(height: AppTheme.md),
                      AppTextField(
                        controller: _treatmentMethodController,
                        label: 'طريقة المعالجة',
                        prefixIcon: Icons.healing,
                      ),
                      const SizedBox(height: AppTheme.md),
                      AppTextField(
                        controller: _chemicalsUsedController,
                        label: 'المواد الكيميائية المستخدمة',
                        prefixIcon: Icons.science,
                      ),
                      const SizedBox(height: AppTheme.md),
                      AppTextField(
                        controller: _notesController,
                        label: 'ملاحظات',
                        prefixIcon: Icons.note,
                        maxLines: 3,
                      ),
                    ] else if (_formData.isNotEmpty) ...[  
                      _buildSectionHeader(context, 'بيانات نموذج المكافحة'),
                      if (_formData['pest_type']?.isNotEmpty ?? false)
                        ListTile(
                          title: const Text('نوع الآفة'),
                          subtitle: Text(_formData['pest_type']),
                          contentPadding: EdgeInsets.zero,
                        ),
                      if (_formData['treatment_method']?.isNotEmpty ?? false)
                        ListTile(
                          title: const Text('طريقة المعالجة'),
                          subtitle: Text(_formData['treatment_method']),
                          contentPadding: EdgeInsets.zero,
                        ),
                      if (_formData['chemicals_used']?.isNotEmpty ?? false)
                        ListTile(
                          title: const Text('المواد الكيميائية المستخدمة'),
                          subtitle: Text(_formData['chemicals_used']),
                          contentPadding: EdgeInsets.zero,
                        ),
                      if (_formData['notes']?.isNotEmpty ?? false)
                        ListTile(
                          title: const Text('ملاحظات'),
                          subtitle: Text(_formData['notes']),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('العلامات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (isEditable) ...[
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  final controller = TextEditingController();
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('إضافة علامة'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: 'اسم العلامة',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(controller.text),
                                          child: const Text('إضافة'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result != null && result.isNotEmpty) {
                                    _addTag(result);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppTheme.xs),
                        Wrap(
                          spacing: AppTheme.xs,
                          children: _tags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: isEditable ? () => _removeTag(tag) : null,
                          )).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.xl),
                    
                    // Save/Complete Button
                     if (isEditable)
                       // للمدير: يظهر زر تحديث/إنشاء عادي
                       if (isAdmin)
                         AppButton(
                           text: _isEditing ? 'تحديث المهمة' : 'إنشاء المهمة',
                           onPressed: _saveTask,
                           isFullWidth: true,
                         )
                       // للموظف: يظهر زر إنهاء المهمة
                       else if (isEmployee && _isEditing && widget.task?.status != 'completed')
                         AppButton(
                           text: 'إنهاء المهمة',
                           onPressed: _completeTask,
                           isFullWidth: true,
                           type: ButtonType.success,
                         )
                       // إذا كانت المهمة مكتملة بالفعل
                       else if (isEmployee && _isEditing && widget.task?.status == 'completed')
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(AppTheme.md),
                           decoration: BoxDecoration(
                             color: Colors.green.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(AppTheme.sm),
                             border: Border.all(color: Colors.green),
                           ),
                           child: const Text(
                             '✅ تم إنهاء هذه المهمة',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               color: Colors.green,
                               fontWeight: FontWeight.bold,
                               fontSize: 16,
                             ),
                           ),
                         )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required bool isEditable,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppTheme.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items,
            onChanged: isEditable ? onChanged : null,
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const Divider(),
        ],
      ),
    );
  }
  
  Widget _buildTimePicker({
    required String label,
    required DateTime? time,
    required Function(DateTime) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppTheme.xs),
        InkWell(
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time != null
                  ? TimeOfDay.fromDateTime(time)
                  : TimeOfDay.now(),
            );
            if (selectedTime != null) {
              final now = DateTime.now();
              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              onSelect(dateTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.md,
              vertical: AppTheme.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: AppTheme.sm),
                Text(
                  time != null
                      ? DateFormat('hh:mm a').format(time)
                      : 'اختر الوقت',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _getEisenhowerClassification() {
    if (_isUrgent && _isImportant) {
      return 'عاجل ومهم (افعل الآن)';
    } else if (_isImportant && !_isUrgent) {
      return 'مهم وغير عاجل (حدد وقتاً له)';
    } else if (_isUrgent && !_isImportant) {
      return 'عاجل وغير مهم (فوضه لغيرك)';
    } else {
      return 'غير عاجل وغير مهم (تجاهله)';
    }
  }
  
  String _getTimeRangeText() {
    String text = '';
    if (_startTime != null) {
      text += 'البدء: ${DateFormat('hh:mm a').format(_startTime!)}';
    }
    if (_endTime != null) {
      if (text.isNotEmpty) text += ' - ';
      text += 'الانتهاء: ${DateFormat('hh:mm a').format(_endTime!)}';
    }
    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      text += '\nالمدة: ';
      if (hours > 0) text += '$hours ساعة ';
      if (minutes > 0) text += '$minutes دقيقة';
    }
    return text.isEmpty ? 'لم يتم تحديد وقت' : text;
  }
}
import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class TaskAdvancedSettingsScreen extends StatefulWidget {
  const TaskAdvancedSettingsScreen({super.key});

  @override
  State<TaskAdvancedSettingsScreen> createState() => _TaskAdvancedSettingsScreenState();
}

class _TaskAdvancedSettingsScreenState extends State<TaskAdvancedSettingsScreen> {
  // إعدادات العرض
  bool _showCompletedTasks = true;
  bool _showTaskDueDates = true;
  bool _showTaskPriority = true;
  bool _showTaskCategories = true;
  String _defaultTaskView = 'قائمة';
  String _defaultSortBy = 'تاريخ الاستحقاق';
  
  // إعدادات المهام الافتراضية
  String _defaultTaskPriority = 'متوسطة';
  String _defaultTaskCategory = 'عام';
  int _defaultReminderTime = 30; // بالدقائق
  
  // خيارات العرض
  final List<String> _viewOptions = ['قائمة', 'بطاقات', 'جدول', 'تقويم'];
  final List<String> _sortOptions = ['تاريخ الاستحقاق', 'الأولوية', 'تاريخ الإنشاء', 'الفئة'];
  
  // خيارات الأولوية
  final List<String> _priorityOptions = ['عالية', 'متوسطة', 'منخفضة'];
  
  // خيارات الفئات
  final List<String> _categoryOptions = ['عام', 'عمل', 'شخصي', 'مشروع', 'مهم'];
  
  // خيارات التذكير
  final List<int> _reminderOptions = [5, 10, 15, 30, 60, 120, 1440]; // بالدقائق (1440 = يوم كامل)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المهام المتقدمة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('خيارات العرض'),
          _buildDisplayCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('الإعدادات الافتراضية للمهام'),
          _buildDefaultTaskSettingsCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('التكامل والتصدير'),
          _buildIntegrationCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('إعدادات متقدمة'),
          _buildAdvancedCard(),
          const SizedBox(height: 24),
          
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  Widget _buildDisplayCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('عرض المهام المكتملة'),
            subtitle: const Text('إظهار المهام المكتملة في القائمة الرئيسية'),
            value: _showCompletedTasks,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _showCompletedTasks = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('عرض تواريخ الاستحقاق'),
            subtitle: const Text('إظهار تواريخ استحقاق المهام في القائمة'),
            value: _showTaskDueDates,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _showTaskDueDates = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('عرض أولوية المهام'),
            subtitle: const Text('إظهار مؤشر الأولوية لكل مهمة'),
            value: _showTaskPriority,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _showTaskPriority = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('عرض فئات المهام'),
            subtitle: const Text('إظهار الفئة المرتبطة بكل مهمة'),
            value: _showTaskCategories,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _showTaskCategories = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('طريقة العرض الافتراضية'),
            trailing: DropdownButton<String>(
              value: _defaultTaskView,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultTaskView = newValue;
                  });
                }
              },
              items: _viewOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('الترتيب الافتراضي'),
            trailing: DropdownButton<String>(
              value: _defaultSortBy,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultSortBy = newValue;
                  });
                }
              },
              items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTaskSettingsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('الأولوية الافتراضية'),
            trailing: DropdownButton<String>(
              value: _defaultTaskPriority,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultTaskPriority = newValue;
                  });
                }
              },
              items: _priorityOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('الفئة الافتراضية'),
            trailing: DropdownButton<String>(
              value: _defaultTaskCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultTaskCategory = newValue;
                  });
                }
              },
              items: _categoryOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('وقت التذكير الافتراضي'),
            trailing: DropdownButton<int>(
              value: _defaultReminderTime,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultReminderTime = newValue;
                  });
                }
              },
              items: _reminderOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(_getReminderTimeText(value)),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('تصدير المهام'),
            subtitle: const Text('تصدير جميع المهام بتنسيق CSV أو JSON'),
            trailing: const Icon(Icons.file_download, color: AppTheme.primary),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('استيراد المهام'),
            subtitle: const Text('استيراد المهام من ملف CSV أو JSON'),
            trailing: const Icon(Icons.file_upload, color: AppTheme.primary),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('مزامنة مع التقويم'),
            subtitle: const Text('مزامنة المهام مع تقويم الجهاز'),
            trailing: const Icon(Icons.sync, color: AppTheme.primary),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('إدارة الفئات'),
            subtitle: const Text('إضافة وتعديل وحذف فئات المهام'),
            trailing: const Icon(Icons.category, color: AppTheme.primary),
            onTap: () {
              _showCategoryManagementDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('إدارة الوسوم'),
            subtitle: const Text('إضافة وتعديل وحذف وسوم المهام'),
            trailing: const Icon(Icons.tag, color: AppTheme.primary),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('إعادة تعيين الإعدادات'),
            subtitle: const Text('إعادة جميع الإعدادات إلى الوضع الافتراضي'),
            trailing: const Icon(Icons.restore, color: Colors.red),
            onTap: () {
              _showResetConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  String _getReminderTimeText(int minutes) {
    if (minutes == 5) return '5 دقائق';
    if (minutes == 10) return '10 دقائق';
    if (minutes == 15) return '15 دقيقة';
    if (minutes == 30) return '30 دقيقة';
    if (minutes == 60) return 'ساعة واحدة';
    if (minutes == 120) return 'ساعتان';
    if (minutes == 1440) return 'يوم واحد';
    return '$minutes دقيقة';
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: () {
          _saveSettings();
        },
        child: const Text('حفظ الإعدادات'),
      ),
    );
  }

  void _saveSettings() {
    // هنا يتم حفظ إعدادات المهام المتقدمة
    // في تطبيق حقيقي، يمكن استخدام SharedPreferences أو قاعدة بيانات
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إعدادات المهام المتقدمة'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  void _showCategoryManagementDialog() {
    final TextEditingController categoryController = TextEditingController();
    final List<String> categories = List.from(_categoryOptions);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة الفئات'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة الجديدة',
                  suffixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (categoryController.text.isNotEmpty) {
                    setState(() {
                      categories.add(categoryController.text);
                      categoryController.clear();
                    });
                  }
                },
                child: const Text('إضافة فئة'),
              ),
              const SizedBox(height: 16),
              const Text('الفئات الحالية:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categories[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            categories.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _categoryOptions.clear();
                _categoryOptions.addAll(categories);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الفئات بنجاح'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إعادة جميع الإعدادات إلى الوضع الافتراضي؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _resetSettings();
              Navigator.pop(context);
            },
            child: const Text('إعادة تعيين', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      // إعادة تعيين إعدادات العرض
      _showCompletedTasks = true;
      _showTaskDueDates = true;
      _showTaskPriority = true;
      _showTaskCategories = true;
      _defaultTaskView = 'قائمة';
      _defaultSortBy = 'تاريخ الاستحقاق';
      
      // إعادة تعيين إعدادات المهام الافتراضية
      _defaultTaskPriority = 'متوسطة';
      _defaultTaskCategory = 'عام';
      _defaultReminderTime = 30;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة تعيين الإعدادات إلى الوضع الافتراضي'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFeatureNotImplementedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ هذه الميزة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
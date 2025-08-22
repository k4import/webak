import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/shared/widgets/widgets.dart';

class StatisticsSettingsScreen extends StatefulWidget {
  const StatisticsSettingsScreen({super.key});

  @override
  State<StatisticsSettingsScreen> createState() => _StatisticsSettingsScreenState();
}

class _StatisticsSettingsScreenState extends State<StatisticsSettingsScreen> {
  // Display settings
  bool _showCompletedTasks = true;
  bool _showInProgressTasks = true;
  bool _showPendingTasks = true;
  String _defaultChartType = 'bar';
  String _defaultTimeRange = 'month';
  
  // Data settings
  bool _includeArchivedTasks = false;
  bool _includeDeletedTasks = false;
  String _dataAggregation = 'daily';
  
  // Export settings
  String _defaultExportFormat = 'pdf';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإحصائيات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisplaySettings(),
            const Divider(),
            _buildDataSettings(),
            const Divider(),
            _buildExportSettings(),
            const Divider(),
            _buildAdvancedSettings(),
            const SizedBox(height: AppTheme.xl),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.lg,
                    vertical: AppTheme.md,
                  ),
                ),
                child: const Text('حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات العرض',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.md),
        SwitchListTile(
          title: const Text('عرض المهام المكتملة'),
          subtitle: const Text('تضمين المهام المكتملة في الرسوم البيانية'),
          value: _showCompletedTasks,
          onChanged: (value) {
            setState(() {
              _showCompletedTasks = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('عرض المهام قيد التنفيذ'),
          subtitle: const Text('تضمين المهام قيد التنفيذ في الرسوم البيانية'),
          value: _showInProgressTasks,
          onChanged: (value) {
            setState(() {
              _showInProgressTasks = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('عرض المهام قيد الانتظار'),
          subtitle: const Text('تضمين المهام قيد الانتظار في الرسوم البيانية'),
          value: _showPendingTasks,
          onChanged: (value) {
            setState(() {
              _showPendingTasks = value;
            });
          },
        ),
        const SizedBox(height: AppTheme.sm),
        ListTile(
          title: const Text('نوع الرسم البياني الافتراضي'),
          subtitle: const Text('اختر نوع الرسم البياني الذي سيتم عرضه افتراضياً'),
          trailing: DropdownButton<String>(
            value: _defaultChartType,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _defaultChartType = newValue;
                });
              }
            },
            items: <String>['bar', 'line', 'pie', 'radar']
                .map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'bar':
                  displayText = 'أعمدة';
                  break;
                case 'line':
                  displayText = 'خطي';
                  break;
                case 'pie':
                  displayText = 'دائري';
                  break;
                case 'radar':
                  displayText = 'راداري';
                  break;
                default:
                  displayText = value;
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('النطاق الزمني الافتراضي'),
          subtitle: const Text('اختر النطاق الزمني الافتراضي للإحصائيات'),
          trailing: DropdownButton<String>(
            value: _defaultTimeRange,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _defaultTimeRange = newValue;
                });
              }
            },
            items: <String>['week', 'month', 'quarter', 'year']
                .map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'week':
                  displayText = 'أسبوع';
                  break;
                case 'month':
                  displayText = 'شهر';
                  break;
                case 'quarter':
                  displayText = 'ربع سنوي';
                  break;
                case 'year':
                  displayText = 'سنة';
                  break;
                default:
                  displayText = value;
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات البيانات',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.md),
        SwitchListTile(
          title: const Text('تضمين المهام المؤرشفة'),
          subtitle: const Text('تضمين المهام المؤرشفة في الإحصائيات'),
          value: _includeArchivedTasks,
          onChanged: (value) {
            setState(() {
              _includeArchivedTasks = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('تضمين المهام المحذوفة'),
          subtitle: const Text('تضمين المهام المحذوفة في الإحصائيات'),
          value: _includeDeletedTasks,
          onChanged: (value) {
            setState(() {
              _includeDeletedTasks = value;
            });
          },
        ),
        ListTile(
          title: const Text('تجميع البيانات'),
          subtitle: const Text('اختر كيفية تجميع البيانات في الإحصائيات'),
          trailing: DropdownButton<String>(
            value: _dataAggregation,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _dataAggregation = newValue;
                });
              }
            },
            items: <String>['daily', 'weekly', 'monthly']
                .map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'daily':
                  displayText = 'يومي';
                  break;
                case 'weekly':
                  displayText = 'أسبوعي';
                  break;
                case 'monthly':
                  displayText = 'شهري';
                  break;
                default:
                  displayText = value;
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExportSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات التصدير',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.md),
        ListTile(
          title: const Text('صيغة التصدير الافتراضية'),
          subtitle: const Text('اختر صيغة التصدير الافتراضية للتقارير'),
          trailing: DropdownButton<String>(
            value: _defaultExportFormat,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _defaultExportFormat = newValue;
                });
              }
            },
            items: <String>['pdf', 'excel', 'csv', 'image']
                .map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'pdf':
                  displayText = 'PDF';
                  break;
                case 'excel':
                  displayText = 'Excel';
                  break;
                case 'csv':
                  displayText = 'CSV';
                  break;
                case 'image':
                  displayText = 'صورة';
                  break;
                default:
                  displayText = value;
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('تصدير التقارير'),
          subtitle: const Text('تصدير جميع التقارير والإحصائيات'),
          trailing: const Icon(Icons.download),
          onTap: _showExportDialog,
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات متقدمة',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.md),
        ListTile(
          title: const Text('إعادة تعيين الإحصائيات'),
          subtitle: const Text('إعادة تعيين جميع الإحصائيات والتقارير'),
          trailing: const Icon(Icons.restore),
          onTap: _showResetConfirmationDialog,
        ),
        ListTile(
          title: const Text('تخصيص المؤشرات'),
          subtitle: const Text('تخصيص المؤشرات الرئيسية في لوحة المعلومات'),
          trailing: const Icon(Icons.dashboard_customize),
          onTap: _showCustomizeMetricsDialog,
        ),
      ],
    );
  }

  void _saveSettings() {
    // Save settings logic will be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير التقارير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر صيغة التصدير:'),
            const SizedBox(height: AppTheme.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportOption('PDF', Icons.picture_as_pdf),
                _buildExportOption('Excel', Icons.table_chart),
                _buildExportOption('CSV', Icons.description),
                _buildExportOption('صورة', Icons.image),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String label, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري تصدير التقارير بصيغة $label'),
            backgroundColor: Colors.blue,
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(label),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإحصائيات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إعادة تعيين جميع الإحصائيات والتقارير؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين الإحصائيات بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إعادة تعيين', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCustomizeMetricsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تخصيص المؤشرات'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildMetricCheckbox('إجمالي المهام', true),
              _buildMetricCheckbox('المهام المكتملة', true),
              _buildMetricCheckbox('المهام قيد التنفيذ', true),
              _buildMetricCheckbox('المهام قيد الانتظار', true),
              _buildMetricCheckbox('نسبة الإنجاز', true),
              _buildMetricCheckbox('متوسط وقت الإنجاز', false),
              _buildMetricCheckbox('المهام المتأخرة', false),
              _buildMetricCheckbox('الإنتاجية الأسبوعية', false),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ تخصيص المؤشرات بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCheckbox(String label, bool initialValue) {
    return CheckboxListTile(
      title: Text(label),
      value: initialValue,
      onChanged: (value) {},
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/theme/theme_cubit.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  bool _analyticsEnabled = true;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'العربية';
  double _textScaleFactor = 1.0;
  
  final List<String> _languages = ['العربية', 'English'];
  final List<double> _textScaleFactors = [0.8, 0.9, 1.0, 1.1, 1.2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات المتقدمة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('الإشعارات والأذونات'),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('تخصيص الواجهة'),
          _buildInterfaceSettings(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('البيانات والخصوصية'),
          _buildPrivacySettings(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('خيارات المطور'),
          _buildDeveloperSettings(),
          const SizedBox(height: 24),
          
          _buildResetButton(),
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

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('استلام إشعارات للمهام والتذكيرات'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('السماح بالوصول للموقع'),
            subtitle: const Text('للحصول على تذكيرات مرتبطة بالموقع'),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterfaceSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('اللغة'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _showFeatureNotImplementedMessage();
                }
              },
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('حجم الخط'),
            trailing: DropdownButton<double>(
              value: _textScaleFactor,
              onChanged: (double? newValue) {
                if (newValue != null) {
                  setState(() {
                    _textScaleFactor = newValue;
                  });
                  // تطبيق حجم الخط الجديد
                  _applyTextScaleFactor(newValue);
                }
              },
              items: _textScaleFactors.map<DropdownMenuItem<double>>((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text('${(value * 100).toInt()}%'),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final themeCubit = context.read<ThemeCubit>();
              final isDarkMode = themeCubit.isDarkMode;
              
              return SwitchListTile(
                title: const Text('الوضع الداكن'),
                subtitle: const Text('تغيير مظهر التطبيق إلى الوضع الداكن'),
                value: isDarkMode,
                onChanged: (value) {
                  themeCubit.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تحليلات الاستخدام'),
            subtitle: const Text('السماح بجمع بيانات مجهولة لتحسين التطبيق'),
            value: _analyticsEnabled,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('المزامنة التلقائية'),
            subtitle: const Text('مزامنة البيانات تلقائياً عند توفر الإنترنت'),
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('حذف جميع البيانات'),
            subtitle: const Text('حذف جميع البيانات المخزنة محلياً'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              _showDeleteDataConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('وضع المطور'),
            trailing: const Icon(Icons.code),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('سجل الأخطاء'),
            trailing: const Icon(Icons.bug_report),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _showResetConfirmationDialog();
        },
        child: const Text('إعادة ضبط جميع الإعدادات'),
      ),
    );
  }

  void _showDeleteDataConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف البيانات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع البيانات المخزنة محلياً؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureNotImplementedMessage();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط الإعدادات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إعادة ضبط جميع الإعدادات إلى الوضع الافتراضي؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllSettings();
            },
            child: const Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }

  void _resetAllSettings() {
    setState(() {
      _notificationsEnabled = true;
      _locationEnabled = false;
      _analyticsEnabled = true;
      _autoSyncEnabled = true;
      _selectedLanguage = 'العربية';
      _textScaleFactor = 1.0;
    });
    
    // إعادة ضبط حجم الخط
    _applyTextScaleFactor(1.0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة ضبط جميع الإعدادات'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _applyTextScaleFactor(double factor) {
    // هذه الدالة ستقوم بتطبيق حجم الخط الجديد
    // في تطبيق حقيقي، يمكن استخدام MediaQuery لتطبيق هذا التغيير
    _showFeatureNotImplementedMessage('تم تغيير حجم الخط');
  }

  void _showFeatureNotImplementedMessage([String message = 'سيتم تنفيذ هذه الميزة قريباً']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
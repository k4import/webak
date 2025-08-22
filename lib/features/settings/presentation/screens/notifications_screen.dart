import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // إعدادات الإشعارات
  bool _allNotificationsEnabled = true;
  bool _taskDueEnabled = true;
  bool _taskReminderEnabled = true;
  bool _newReportEnabled = true;
  bool _systemUpdatesEnabled = false;
  
  // إعدادات الصوت والاهتزاز
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // وقت الإشعارات
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _reminderDays = 1;
  
  // قائمة أيام التذكير
  final List<int> _reminderDayOptions = [0, 1, 2, 3, 7];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMasterSwitch(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('أنواع الإشعارات'),
          _buildNotificationTypesCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('خيارات الإشعارات'),
          _buildNotificationOptionsCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('توقيت التذكيرات'),
          _buildReminderTimingCard(),
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

  Widget _buildMasterSwitch() {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: const Text(
          'تفعيل جميع الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('إيقاف هذا الخيار سيوقف جميع الإشعارات'),
        value: _allNotificationsEnabled,
        activeColor: AppTheme.primary,
        onChanged: (value) {
          setState(() {
            _allNotificationsEnabled = value;
            if (!value) {
              // إيقاف جميع الإشعارات
              _taskDueEnabled = false;
              _taskReminderEnabled = false;
              _newReportEnabled = false;
              _systemUpdatesEnabled = false;
            }
          });
        },
      ),
    );
  }

  Widget _buildNotificationTypesCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('موعد استحقاق المهام'),
            subtitle: const Text('إشعارات عند حلول موعد استحقاق المهام'),
            value: _allNotificationsEnabled && _taskDueEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _taskDueEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('تذكيرات المهام'),
            subtitle: const Text('تذكيرات قبل موعد استحقاق المهام'),
            value: _allNotificationsEnabled && _taskReminderEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _taskReminderEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('تقارير جديدة'),
            subtitle: const Text('إشعارات عند إنشاء تقارير جديدة'),
            value: _allNotificationsEnabled && _newReportEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _newReportEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('تحديثات النظام'),
            subtitle: const Text('إشعارات حول تحديثات وميزات جديدة'),
            value: _allNotificationsEnabled && _systemUpdatesEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _systemUpdatesEnabled = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOptionsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('الصوت'),
            subtitle: const Text('تشغيل صوت مع الإشعارات'),
            value: _allNotificationsEnabled && _soundEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('الاهتزاز'),
            subtitle: const Text('تفعيل الاهتزاز مع الإشعارات'),
            value: _allNotificationsEnabled && _vibrationEnabled,
            activeColor: AppTheme.primary,
            onChanged: _allNotificationsEnabled
                ? (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimingCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('وقت التذكير اليومي'),
            subtitle: Text(
              'سيتم إرسال تذكير يومي في الساعة ${_reminderTime.format(context)}',
            ),
            trailing: const Icon(Icons.access_time),
            enabled: _allNotificationsEnabled && _taskReminderEnabled,
            onTap: (_allNotificationsEnabled && _taskReminderEnabled)
                ? () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null && picked != _reminderTime) {
                      setState(() {
                        _reminderTime = picked;
                      });
                    }
                  }
                : null,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('التذكير قبل الموعد النهائي'),
            subtitle: Text(_getReminderDaysText()),
            trailing: DropdownButton<int>(
              value: _reminderDays,
              onChanged: (_allNotificationsEnabled && _taskReminderEnabled)
                  ? (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _reminderDays = newValue;
                        });
                      }
                    }
                  : null,
              items: _reminderDayOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(_getDayText(value)),
                );
              }).toList(),
              underline: Container(),
            ),
            enabled: _allNotificationsEnabled && _taskReminderEnabled,
          ),
        ],
      ),
    );
  }

  String _getReminderDaysText() {
    return 'تذكير قبل ${_getDayText(_reminderDays)} من الموعد النهائي';
  }

  String _getDayText(int days) {
    if (days == 0) return 'نفس اليوم';
    if (days == 1) return 'يوم واحد';
    if (days == 2) return 'يومين';
    return '$days أيام';
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
          _saveNotificationSettings();
        },
        child: const Text('حفظ الإعدادات'),
      ),
    );
  }

  void _saveNotificationSettings() {
    // هنا يتم حفظ إعدادات الإشعارات
    // في تطبيق حقيقي، يمكن استخدام SharedPreferences أو قاعدة بيانات
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إعدادات الإشعارات'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
}
import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // إعدادات الخصوصية
  bool _locationTrackingEnabled = false;
  bool _analyticsEnabled = true;
  bool _personalizationEnabled = true;
  
  // إعدادات الأمان
  bool _biometricAuthEnabled = false;
  bool _twoFactorAuthEnabled = false;
  int _autoLockTimeout = 5; // بالدقائق
  
  // خيارات قفل التطبيق
  final List<int> _lockTimeoutOptions = [0, 1, 5, 10, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخصوصية والأمان'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('الخصوصية'),
          _buildPrivacyCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('الأمان'),
          _buildSecurityCard(),
          const SizedBox(height: 16),
          
          _buildSectionTitle('البيانات'),
          _buildDataCard(),
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

  Widget _buildPrivacyCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تتبع الموقع'),
            subtitle: const Text('السماح للتطبيق بالوصول إلى موقعك لتحسين التجربة'),
            value: _locationTrackingEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _locationTrackingEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('تحليلات الاستخدام'),
            subtitle: const Text('مشاركة بيانات الاستخدام المجهولة لتحسين التطبيق'),
            value: _analyticsEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('تخصيص المحتوى'),
            subtitle: const Text('تخصيص المحتوى بناءً على نشاطك'),
            value: _personalizationEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _personalizationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('المصادقة البيومترية'),
            subtitle: const Text('استخدام بصمة الإصبع أو التعرف على الوجه لتسجيل الدخول'),
            value: _biometricAuthEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _biometricAuthEnabled = value;
              });
              if (value) {
                _showFeatureNotImplementedMessage('سيتم تفعيل المصادقة البيومترية قريباً');
              }
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('المصادقة الثنائية'),
            subtitle: const Text('تأمين إضافي لحسابك باستخدام رمز التحقق'),
            value: _twoFactorAuthEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _twoFactorAuthEnabled = value;
              });
              if (value) {
                _showFeatureNotImplementedMessage('سيتم تفعيل المصادقة الثنائية قريباً');
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('قفل تلقائي للتطبيق'),
            subtitle: Text(_getLockTimeoutText()),
            trailing: DropdownButton<int>(
              value: _autoLockTimeout,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _autoLockTimeout = newValue;
                  });
                }
              },
              items: _lockTimeoutOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(_getTimeoutText(value)),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('تغيير كلمة المرور'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('تصدير البيانات'),
            subtitle: const Text('تصدير جميع بياناتك بتنسيق JSON'),
            trailing: const Icon(Icons.download, color: AppTheme.primary),
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('حذف البيانات المخزنة محلياً'),
            subtitle: const Text('حذف جميع البيانات المخزنة على هذا الجهاز'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              _showDeleteDataConfirmationDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('حذف الحساب'),
            subtitle: const Text('حذف حسابك وجميع بياناتك نهائياً'),
            trailing: const Icon(Icons.no_accounts, color: Colors.red),
            onTap: () {
              _showDeleteAccountConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  String _getLockTimeoutText() {
    return 'قفل التطبيق تلقائياً بعد ${_getTimeoutText(_autoLockTimeout)}';
  }

  String _getTimeoutText(int minutes) {
    if (minutes == 0) return 'إيقاف';
    if (minutes == 1) return 'دقيقة واحدة';
    return '$minutes دقائق';
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
          _savePrivacySettings();
        },
        child: const Text('حفظ الإعدادات'),
      ),
    );
  }

  void _savePrivacySettings() {
    // هنا يتم حفظ إعدادات الخصوصية والأمان
    // في تطبيق حقيقي، يمكن استخدام SharedPreferences أو قاعدة بيانات
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إعدادات الخصوصية والأمان'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                ),
                obscureText: true,
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
              Navigator.pop(context);
              _showFeatureNotImplementedMessage('سيتم تنفيذ تغيير كلمة المرور قريباً');
            },
            child: const Text('تغيير'),
          ),
        ],
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
              _showFeatureNotImplementedMessage('سيتم تنفيذ حذف البيانات قريباً');
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ سيتم حذف جميع بياناتك ولا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureNotImplementedMessage('سيتم تنفيذ حذف الحساب قريباً');
            },
            child: const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
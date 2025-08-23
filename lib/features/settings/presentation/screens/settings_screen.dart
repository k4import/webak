import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/theme/theme_cubit.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/settings/presentation/screens/advanced_settings_screen.dart';
import 'package:webak/features/settings/presentation/screens/help_screen.dart';
import 'package:webak/features/settings/presentation/screens/notifications_screen.dart';
import 'package:webak/features/settings/presentation/screens/privacy_security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'العربية';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.md),
        children: [
          _buildSectionTitle('الحساب'),
          _buildAccountSettings(),
          const SizedBox(height: AppTheme.lg),
          
          _buildSectionTitle('المظهر'),
          _buildAppearanceSettings(),
          const SizedBox(height: AppTheme.lg),
          
          _buildSectionTitle('الإشعارات'),
          _buildNotificationSettings(),
          const SizedBox(height: AppTheme.lg),
          
          _buildSectionTitle('اللغة'),
          _buildLanguageSettings(),
          const SizedBox(height: AppTheme.lg),
          
          _buildSectionTitle('حول التطبيق'),
          _buildAboutSettings(),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildAccountSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primary),
            title: const Text('تعديل الملف الشخصي'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showFeatureComingSoon();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security, color: AppTheme.primary),
            title: const Text('الخصوصية والأمان'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primary),
            title: const Text('تغيير كلمة المرور'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showFeatureComingSoon();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppearanceSettings() {
    return Card(
      child: Column(
        children: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final themeCubit = context.read<ThemeCubit>();
              final isDarkMode = state is ThemeLoaded ? state.themeMode == ThemeMode.dark : false;
              
              return SwitchListTile(
                title: const Text('الوضع الداكن'),
                secondary: Icon(
                  Icons.dark_mode, 
                  color: isDarkMode ? AppTheme.primaryDark : AppTheme.primary
                ),
                value: isDarkMode,
                onChanged: (value) {
                  themeCubit.toggleTheme();
                },
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.color_lens, color: AppTheme.primary),
            title: const Text('تخصيص الألوان'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showFeatureComingSoon();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            secondary: const Icon(Icons.notifications, color: AppTheme.primary),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: AppTheme.primary),
            title: const Text('إعدادات الإشعارات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_applications, color: AppTheme.primary),
            title: const Text('الإعدادات المتقدمة'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSettings() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language, color: AppTheme.primary),
        title: const Text('اللغة'),
        trailing: DropdownButton<String>(
          value: _language,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'العربية', child: Text('العربية')),
            DropdownMenuItem(value: 'English', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _language = value;
              });
              _showFeatureComingSoon();
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildAboutSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primary),
            title: const Text('عن التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.update, color: AppTheme.primary),
            title: const Text('التحقق من التحديثات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showFeatureComingSoon();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help, color: AppTheme.primary),
            title: const Text('المساعدة والدعم'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showFeatureComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ هذه الميزة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _showLogoutConfirmation() {
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
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'وبك - إدارة المهام',
        applicationVersion: '1.0.0',
        applicationIcon: Image.asset('assets/images/logo.png', width: 48, height: 48),
        applicationLegalese: '© 2023 وبك. جميع الحقوق محفوظة.',
        children: [
          const SizedBox(height: AppTheme.md),
          const Text(
            'تطبيق وبك هو تطبيق لإدارة المهام والمشاريع بطريقة سهلة وفعالة. يساعدك على تنظيم مهامك وتتبع تقدمك وإنشاء تقارير مفصلة.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
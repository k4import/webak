import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/responsive_utils.dart';
import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    
    // تعبئة البيانات الحالية
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _usernameController.text = user.username ?? '';
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.metadata?['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // إعادة تعبئة البيانات الأصلية
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    final user = authState.user;
                    _usernameController.text = user.username ?? '';
                    _fullNameController.text = user.fullName ?? '';
                    _emailController.text = user.email;
                    _phoneController.text = user.metadata?['phone'] ?? '';
                  }
                });
              },
            ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return ResponsiveUtils.buildResponsiveContainer(
              context: context,
              maxWidth: 600,
              child: SingleChildScrollView(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: AppTheme.lg),
                    _buildProfileForm(),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: ResponsiveUtils.isMobile(context) ? 50 : 60,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.email.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 40),
                      ),
                    )
                  : null,
            ),
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    // TODO: تنفيذ تغيير الصورة الشخصية
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم تنفيذ هذه الميزة قريباً'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.md),
        Text(
            user.fullName ?? user.username ?? user.email ?? 'مستخدم',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
            user.email,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: Icon(Icons.person),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم المستخدم';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.md),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.badge),
            ),
            enabled: _isEditing,
          ),
          const SizedBox(height: AppTheme.md),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال البريد الإلكتروني';
              }
              if (!value.contains('@')) {
                return 'الرجاء إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.md),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
            enabled: _isEditing,
          ),
          const SizedBox(height: AppTheme.xl),
          if (_isEditing)
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('حفظ التغييرات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.lg,
                    vertical: AppTheme.sm,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppTheme.lg),
          // Admin logout button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && state.user.role == 'admin') {
                return Column(
                  children: [
                    Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                title: const Text('تسجيل خروج المدير', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
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
                   ],
                 );
               } else {
                 return Column(
                   children: [
                     const SizedBox(height: AppTheme.lg),
                     // Regular logout button for non-admin users
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
                                     Navigator.of(context).pushNamedAndRemoveUntil(
                                       '/login',
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
                 );
               }
               return const SizedBox.shrink();
             },
           ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: تنفيذ حفظ التغييرات عند إضافة الميزة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: AppTheme.success,
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }
}
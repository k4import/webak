import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/utils/app_utils.dart';
import 'package:webak/core/utils/responsive_utils.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/auth/presentation/screens/register_screen.dart';
import 'package:webak/features/tasks/presentation/screens/dashboard_screen.dart';
import 'package:webak/shared/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppUtils.showSnackBar(
              context: context,
              message: state.message,
              isError: true,
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppTheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: ResponsiveUtils.buildResponsiveContainer(
                context: context,
                maxWidth: 400,
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          // Logo and Title with Animation
                          Hero(
                            tag: 'app_logo',
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.elasticOut,
                              ),
                              child: Lottie.asset(
                                'assets/animations/task_animation.json',
                                height: 150,
                                width: 150,
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                            )),
                            child: Text(
                              'مرحباً بك في وبك',
                              style: AppTheme.h2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          FadeTransition(
                            opacity: _animationController,
                            child: Text(
                              'سجل دخولك لإدارة مهامك بكفاءة',
                              style: AppTheme.body1.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xl),

                          // Email Field with Animation
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                            )),
                            child: AppTextField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
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
                          ),
                          const SizedBox(height: AppTheme.md),

                          // Password Field with Animation
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                            )),
                            child: AppTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              prefixIcon: Icons.lock_outline,
                              isPassword: !_isPasswordVisible,
                              suffix: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),

                          // Login Button with Animation
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                            ),
                            child: AppButton(
                              text: 'تسجيل الدخول',
                              isLoading: state is AuthLoading,
                              onPressed: _login,
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),

                          // Register Link with Animation
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ليس لديك حساب؟',
                                  style: AppTheme.body2,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'إنشاء حساب',
                                    style: AppTheme.body2.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
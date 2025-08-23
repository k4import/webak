import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:webak/core/config/dependency_injection.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/theme/app_colors.dart';
import 'package:webak/core/theme/app_icons.dart';
import 'package:webak/core/theme/app_animations.dart';
import 'package:webak/core/theme/theme_cubit.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/auth/presentation/screens/login_screen.dart';
import 'package:webak/features/reports/presentation/cubit/report_cubit.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/features/tasks/presentation/screens/dashboard_screen.dart';

import 'core/config/database_config.dart';
import 'core/utils/cache_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Windows
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // تحسين الأداء وتقليل استخدام GPU
  // تقليل معدل الإطارات لتوفير الطاقة
  WidgetsBinding.instance.platformDispatcher.onBeginFrame = null;
  
  // Initialize Cache Helper
  await CacheHelper.init();

  // Initialize Local Database
  await DatabaseConfig.instance.initialize();

  // Initialize dependency injection
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => GetIt.I<AuthCubit>(),
        ),
        BlocProvider<TaskCubit>(
          create: (context) => GetIt.I<TaskCubit>(),
        ),
        BlocProvider<ReportCubit>(
          create: (context) => GetIt.I<ReportCubit>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => GetIt.I<ThemeCubit>()..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'وبك - إدارة المهام',
            debugShowCheckedModeBanner: false,
            themeMode: context.read<ThemeCubit>().themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      // Check authentication status using AuthCubit
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to Dashboard if authenticated
          Navigator.of(context).pushReplacement(
            AppAnimations.fadeTransition(const DashboardScreen()),
          );
        } else if (state is AuthUnauthenticated) {
          // Navigate to Login if not authenticated
          Navigator.of(context).pushReplacement(
            AppAnimations.fadeTransition(const LoginScreen()),
          );
        }
        // For other states (loading, error), stay on splash screen
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار التطبيق مع رسم متحرك
                AppAnimations.successAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.xl),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: const Icon(
                      AppIcons.pestControl,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.xl),
                
                // اسم التطبيق
                AppAnimations.listItemAnimation(
                  index: 0,
                  child: Text(
                    'وبك',
                    style: AppTheme.h1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                
                // وصف التطبيق
                AppAnimations.listItemAnimation(
                  index: 1,
                  child: Text(
                    'إدارة مهام مكافحة الآفات والتحديات البيئية',
                    style: AppTheme.body1.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppTheme.xxxl),
                
                // مؤشر التحميل
                AppAnimations.listItemAnimation(
                  index: 2,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

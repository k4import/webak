import 'package:flutter/material.dart';

/// مجموعة شاملة من الألوان المستخدمة في التطبيق
class AppColors {
  // الألوان الأساسية للتطبيق
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryOrange = Color(0xFFFF8F00);
  static const Color primaryBlue = Color(0xFF1976D2);
  
  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // ألوان الخلفية
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // ألوان النص
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // ألوان خاصة بتطبيق مكافحة الآفات
  static const Color pestControlGreen = Color(0xFF388E3C);
  static const Color environmentGreen = Color(0xFF66BB6A);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color dangerRed = Color(0xFFD32F2F);
  
  // ألوان أولوية المهام
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityLow = Color(0xFF4CAF50);
  
  // ألوان حالة المهام
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFF9E9E9E);
  
  // ألوان متدرجة للخلفيات
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ألوان شفافة للتراكبات
  static const Color overlay = Color(0x80000000);
  static const Color lightOverlay = Color(0x40000000);
  
  // ألوان الحدود والفواصل
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2E2E2E);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF2E2E2E);
  
  /// الحصول على لون الأولوية
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'عالية':
        return priorityHigh;
      case 'medium':
      case 'متوسطة':
        return priorityMedium;
      case 'low':
      case 'منخفضة':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }
  
  /// الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'معلقة':
        return statusPending;
      case 'in_progress':
      case 'قيد التنفيذ':
        return statusInProgress;
      case 'completed':
      case 'مكتملة':
        return statusCompleted;
      case 'cancelled':
      case 'ملغية':
        return statusCancelled;
      default:
        return statusPending;
    }
  }
}
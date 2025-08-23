import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webak/core/theme/app_colors.dart';
import 'package:webak/core/theme/app_icons.dart';
import 'package:webak/features/tasks/domain/enums/task_priorities.dart';

class AppUtils {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // Show Snackbar
  static void showSnackBar({required BuildContext context, required String message, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show Loading Dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('جاري التحميل...'),
          ],
        ),
      ),
    );
  }

  // Show Confirmation Dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Get Priority Color (Enhanced)
  static Color getPriorityColor(dynamic priority) {
    if (priority is String) {
      return AppColors.getPriorityColor(priority);
    }
    
    // Handle TaskPriorities enum
    if (priority is TaskPriorities) {
      switch (priority) {
        case TaskPriorities.urgent:
          return AppColors.priorityHigh;
        case TaskPriorities.high:
          return AppColors.priorityHigh;
        case TaskPriorities.medium:
          return AppColors.priorityMedium;
        case TaskPriorities.low:
          return AppColors.priorityLow;
      }
    }
    
    return AppColors.priorityMedium;
  }

  // Get Status Color (Enhanced)
  static Color getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }
  
  // Get Priority Icon
  static IconData getPriorityIcon(String priority) {
    return AppIcons.getPriorityIcon(priority);
  }
  
  // Get Status Icon
  static IconData getStatusIcon(String status) {
    return AppIcons.getStatusIcon(status);
  }
  
  // Show Enhanced Snackbar with animation
  static void showEnhancedSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration? duration,
    IconData? icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration ?? const Duration(seconds: 3),
      elevation: 4,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
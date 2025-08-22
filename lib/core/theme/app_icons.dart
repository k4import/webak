import 'package:flutter/material.dart';

/// مجموعة من الأيقونات المستخدمة في التطبيق
class AppIcons {
  // أيقونات التنقل الأساسية
  static const IconData home = Icons.home_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData tasks = Icons.task_alt_rounded;
  static const IconData reports = Icons.analytics_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData profile = Icons.person_rounded;
  
  // أيقونات المهام
  static const IconData addTask = Icons.add_task_rounded;
  static const IconData editTask = Icons.edit_rounded;
  static const IconData deleteTask = Icons.delete_rounded;
  static const IconData taskCompleted = Icons.check_circle_rounded;
  static const IconData taskPending = Icons.pending_rounded;
  static const IconData taskInProgress = Icons.hourglass_empty_rounded;
  
  // أيقونات الأولوية
  static const IconData priorityHigh = Icons.priority_high_rounded;
  static const IconData priorityMedium = Icons.remove_rounded;
  static const IconData priorityLow = Icons.keyboard_arrow_down_rounded;
  
  // أيقونات مكافحة الآفات
  static const IconData pestControl = Icons.bug_report_rounded;
  static const IconData spray = Icons.water_drop_rounded;
  static const IconData inspection = Icons.search_rounded;
  static const IconData treatment = Icons.healing_rounded;
  static const IconData environment = Icons.eco_rounded;
  static const IconData safety = Icons.security_rounded;
  
  // أيقونات الموقع والتاريخ
  static const IconData location = Icons.location_on_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData date = Icons.date_range_rounded;
  
  // أيقونات الإجراءات
  static const IconData save = Icons.save_rounded;
  static const IconData cancel = Icons.cancel_rounded;
  static const IconData confirm = Icons.check_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  
  // أيقونات التواصل
  static const IconData phone = Icons.phone_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData message = Icons.message_rounded;
  static const IconData notification = Icons.notifications_rounded;
  
  // أيقونات الملفات والوسائط
  static const IconData file = Icons.description_rounded;
  static const IconData image = Icons.image_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData gallery = Icons.photo_library_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;
  
  // أيقونات المستخدم والمصادقة
  static const IconData login = Icons.login_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData register = Icons.person_add_rounded;
  static const IconData password = Icons.lock_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  
  // أيقونات الحالة
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;
  
  // أيقونات التصفية والبحث
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData clear = Icons.clear_rounded;
  
  // أيقونات القوائم والعرض
  static const IconData list = Icons.list_rounded;
  static const IconData grid = Icons.grid_view_rounded;
  static const IconData card = Icons.view_agenda_rounded;
  static const IconData expand = Icons.expand_more_rounded;
  static const IconData collapse = Icons.expand_less_rounded;
  
  // أيقونات الإعدادات
  static const IconData theme = Icons.palette_rounded;
  static const IconData language = Icons.language_rounded;
  static const IconData help = Icons.help_rounded;
  static const IconData about = Icons.info_outline_rounded;
  
  /// الحصول على أيقونة الأولوية
  static IconData getPriorityIcon(String priority) {
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
  
  /// الحصول على أيقونة الحالة
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'معلقة':
        return taskPending;
      case 'in_progress':
      case 'قيد التنفيذ':
        return taskInProgress;
      case 'completed':
      case 'مكتملة':
        return taskCompleted;
      default:
        return taskPending;
    }
  }
  
  /// إنشاء أيقونة مع لون مخصص
  static Widget coloredIcon({
    required IconData icon,
    required Color color,
    double? size,
  }) {
    return Icon(
      icon,
      color: color,
      size: size ?? 24.0,
    );
  }
  
  /// إنشاء أيقونة مع خلفية دائرية
  static Widget circularIcon({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    double? size,
    double? iconSize,
  }) {
    return Container(
      width: size ?? 40.0,
      height: size ?? 40.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize ?? 20.0,
      ),
    );
  }
}
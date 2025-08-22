class AppConstants {
  // App Info
  static const String appName = 'تطبيق إدارة مهام الفنيين';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String tasksTable = 'tasks';
  static const String reportsTable = 'reports';
  static const String usersTable = 'users';
  
  // Task Types
  static const String routineControl = 'مكافحة دورية';
  static const String emergencyReport = 'بلاغ طارئ';
  static const String followUpInspection = 'متابعة وفحص';
  
  // Task Priorities (Eisenhower Matrix)
  static const String urgentImportant = 'عاجل ومهم';
  static const String urgentNotImportant = 'عاجل وغير مهم';
  static const String importantNotUrgent = 'مهم وغير عاجل';
  static const String notImportantNotUrgent = 'غير مهم وغير عاجل';
  
  // Task Status
  static const String pending = 'قيد الانتظار';
  static const String inProgress = 'قيد التنفيذ';
  static const String completed = 'مكتمل';
  static const String cancelled = 'ملغي';
  
  // AI Integration
  static const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
}
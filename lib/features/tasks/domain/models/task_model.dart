import 'package:flutter/material.dart';

class TaskModel {
  final String? id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? location;
  final DateTime? startTime; // وقت بدء المهمة
  final DateTime? endTime; // وقت انتهاء المهمة
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final String? assignedTo;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? formData; // بيانات النموذج المدخلة
  final bool isUrgent; // هل المهمة عاجلة
  final bool isImportant; // هل المهمة مهمة

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.location,
    this.startTime,
    this.endTime,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.assignedTo,
    this.tags,
    this.metadata,
    this.formData,
    this.isUrgent = false,
    this.isImportant = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      location: json['location'],
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userId: json['user_id'],
      assignedTo: json['assigned_to'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metadata: json['metadata'],
      formData: json['form_data'],
      isUrgent: json['is_urgent'] ?? false,
      isImportant: json['is_important'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'location': location,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'assigned_to': assignedTo,
      'tags': tags,
      'metadata': metadata,
      'form_data': formData,
      'is_urgent': isUrgent,
      'is_important': isImportant,
    };
  }

  // Helper factory to create a task from SQLite database
  factory TaskModel.fromSQLite(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'medium',
      location: map['location'],
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'])
          : null,
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'])
          : null,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      userId: map['user_id'],
      assignedTo: map['assigned_to'],
      tags: map['tags'] != null && map['tags'] is List
          ? List<String>.from(map['tags'])
          : map['tags'] is String && (map['tags'] as String).isNotEmpty
              ? (map['tags'] as String).split(',')
              : null,
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      formData: map['form_data'] is Map
          ? Map<String, dynamic>.from(map['form_data'])
          : null,
      isUrgent: map['is_urgent'] == 1 || map['is_urgent'] == true,
      isImportant: map['is_important'] == 1 || map['is_important'] == true,
    );
  }

  // Helper method to convert to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'location': location,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'user_id': userId,
      'assigned_to': assignedTo,
      'tags': tags != null ? tags!.join(',') : null,
      'metadata': metadata != null ? metadata.toString() : null,
      'form_data': formData != null ? formData.toString() : null,
      'is_urgent': isUrgent ? 1 : 0,
      'is_important': isImportant ? 1 : 0,
    };
  }
  
  // Helper methods for task categorization
  bool get isEisenhowerUrgentImportant => isUrgent && isImportant;
  bool get isEisenhowerUrgentNotImportant => isUrgent && !isImportant;
  bool get isEisenhowerNotUrgentImportant => !isUrgent && isImportant;
  bool get isEisenhowerNotUrgentNotImportant => !isUrgent && !isImportant;

  // Get color based on priority
  Color getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Get icon based on status
  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Format time for display
  String getFormattedStartTime() {
    return startTime != null
        ? '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'
        : 'غير محدد';
  }

  String getFormattedEndTime() {
    return endTime != null
        ? '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'
        : 'غير محدد';
  }

  // Get duration in minutes
  int? getDurationMinutes() {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!).inMinutes;
    }
    return null;
  }

  // Get formatted duration
  String getFormattedDuration() {
    final minutes = getDurationMinutes();
    if (minutes == null) return 'غير محدد';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '$hours ساعة ${remainingMinutes > 0 ? 'و $remainingMinutes دقيقة' : ''}';
    } else {
      return '$minutes دقيقة';
    }
  }
  
  // CopyWith method to create a copy of the task with optional new values
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? assignedTo,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? formData,
    bool? isUrgent,
    bool? isImportant,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      formData: formData ?? this.formData,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
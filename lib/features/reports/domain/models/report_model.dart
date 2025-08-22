import 'dart:convert';

class ReportModel {
  final String? id;
  final String title;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final List<String>? taskIds;

  ReportModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,

    this.createdAt,
    this.updatedAt,
    this.userId,
    this.metadata,
    this.taskIds,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'weekly',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : DateTime.now(),

      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userId: json['user_id'],
      metadata: json['metadata'],
      taskIds: json['task_ids'] != null ? List<String>.from(json['task_ids']) : null,
    );
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,

    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Map<String, dynamic>? metadata,
    List<String>? taskIds,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      taskIds: taskIds ?? this.taskIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'metadata': metadata,
      'task_ids': taskIds,
    };
  }

  // Helper factory to create a report from SQLite response
  factory ReportModel.fromSQLite(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'weekly',
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : DateTime.now(),

      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      userId: map['user_id'],
      metadata: map['metadata'] != null ? map['metadata'] is String ? jsonDecode(map['metadata']) : map['metadata'] : null,
      taskIds: map['task_ids'] != null
          ? map['task_ids'] is String ? List<String>.from(jsonDecode(map['task_ids'])) : List<String>.from(map['task_ids'])
          : null,
    );
  }

  // Helper method to convert to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),

      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (metadata != null) 'metadata': jsonEncode(metadata),
      if (taskIds != null) 'task_ids': jsonEncode(taskIds),
    };
  }
}
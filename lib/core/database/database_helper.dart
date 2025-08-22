import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  bool _isInitialized = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    _isInitialized = true;
    return _database!;
  }
  
  bool get isInitialized => _isInitialized;

  Future<Database> _initDatabase() async {
    // Initialize sqflite for web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    String path = join(await getDatabasesPath(), 'webak_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        location TEXT,
        start_time TEXT,
        end_time TEXT,
        due_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        user_id TEXT,
        assigned_to TEXT,
        tags TEXT,
        metadata TEXT,
        form_data TEXT,
        is_urgent INTEGER NOT NULL,
        is_important INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE reports(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        user_id TEXT,
        metadata TEXT,
        task_ids TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        username TEXT,
        full_name TEXT,
        avatar_url TEXT,
        last_sign_in_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        role TEXT NOT NULL,
        metadata TEXT
      )
    ''');
    
    // Insert default admin user
    await db.insert('users', {
      'id': const Uuid().v4(),
      'email': 'admin@example.com',
      'password': 'admin123',
      'username': 'admin',
      'full_name': 'Admin User',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Insert default employee user
    final employeeId = const Uuid().v4();
    await db.insert('users', {
      'id': employeeId,
      'email': 'employee@example.com',
      'password': 'employee123',
      'username': 'employee',
      'full_name': 'Employee User',
      'role': 'employee',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert additional employee user
    await db.insert('users', {
      'id': const Uuid().v4(),
      'email': 'emp@mail.com',
      'password': '12345678',
      'username': 'emp',
      'full_name': 'Employee',
      'role': 'employee',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert additional manager user
    await db.insert('users', {
      'id': const Uuid().v4(),
      'email': 'mange@mail.com',
      'password': '12345678',
      'username': 'manager',
      'full_name': 'Manager',
      'role': 'manager',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert default pest control and environmental tasks for Saudi Arabia
    final defaultTasks = [
      {
        'id': const Uuid().v4(),
        'title': 'مكافحة النمل الأبيض في المباني السكنية',
        'description': 'فحص وعلاج المباني السكنية من النمل الأبيض في منطقة الرياض. يشمل الفحص الشامل للأساسات والهياكل الخشبية وتطبيق المبيدات المناسبة.',
        'status': 'pending',
        'priority': 'high',
        'location': 'الرياض - حي النرجس',
        'start_time': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 1, hours: 4)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'مكافحة الحشرات,النمل الأبيض,المباني السكنية',
        'is_urgent': 1,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'مكافحة الصراصير في المطاعم والمقاهي',
        'description': 'تنفيذ برنامج مكافحة الصراصير في المطاعم والمقاهي بجدة. يتضمن الرش الوقائي وتركيب الطعوم والمتابعة الدورية.',
        'status': 'pending',
        'priority': 'high',
        'location': 'جدة - شارع التحلية',
        'start_time': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 2, hours: 3)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'مكافحة الحشرات,الصراصير,المطاعم',
        'is_urgent': 1,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'مكافحة البعوض في المناطق السكنية',
        'description': 'رش المبيدات لمكافحة البعوض في الأحياء السكنية بالدمام، خاصة في المناطق القريبة من المسطحات المائية والحدائق.',
        'status': 'pending',
        'priority': 'medium',
        'location': 'الدمام - حي الفيصلية',
        'start_time': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 3, hours: 5)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'مكافحة الحشرات,البعوض,المناطق السكنية',
        'is_urgent': 0,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'مكافحة العقارب في المناطق الصحراوية',
        'description': 'تنفيذ برنامج مكافحة العقارب في المناطق الصحراوية حول مدينة الرياض، مع التركيز على المناطق السكنية الجديدة.',
        'status': 'pending',
        'priority': 'high',
        'location': 'الرياض - المناطق الصحراوية',
        'start_time': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 4, hours: 6)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 6)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'مكافحة الحشرات,العقارب,المناطق الصحراوية',
        'is_urgent': 1,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'مراقبة جودة الهواء في المناطق الصناعية',
        'description': 'قياس ومراقبة جودة الهواء في المناطق الصناعية بالجبيل، وتحليل مستويات التلوث وإعداد التقارير البيئية.',
        'status': 'pending',
        'priority': 'medium',
        'location': 'الجبيل - المنطقة الصناعية',
        'start_time': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 5, hours: 8)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'البيئة,جودة الهواء,المناطق الصناعية',
        'is_urgent': 0,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'معالجة تلوث المياه الجوفية',
        'description': 'فحص ومعالجة تلوث المياه الجوفية في منطقة القصيم، وتطبيق الحلول البيئية المناسبة لحماية المصادر المائية.',
        'status': 'pending',
        'priority': 'high',
        'location': 'القصيم - بريدة',
        'start_time': DateTime.now().add(const Duration(days: 6)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 6, hours: 7)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'البيئة,تلوث المياه,المياه الجوفية',
        'is_urgent': 1,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'مكافحة الجراد الصحراوي',
        'description': 'رصد ومكافحة أسراب الجراد الصحراوي في المناطق الزراعية بالقصيم وحائل، وتطبيق المبيدات البيولوجية الآمنة.',
        'status': 'pending',
        'priority': 'high',
        'location': 'القصيم - المناطق الزراعية',
        'start_time': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 7, hours: 10)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 9)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'مكافحة الحشرات,الجراد الصحراوي,الزراعة',
        'is_urgent': 1,
        'is_important': 1,
      },
      {
        'id': const Uuid().v4(),
        'title': 'تنظيف وإعادة تأهيل الشواطئ',
        'description': 'تنظيف الشواطئ من التلوث البلاستيكي والنفطي في منطقة الخبر، وإعادة تأهيل النظم البيئية البحرية.',
        'status': 'pending',
        'priority': 'medium',
        'location': 'الخبر - الكورنيش',
        'start_time': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
        'end_time': DateTime.now().add(const Duration(days: 8, hours: 6)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'user_id': employeeId,
        'assigned_to': employeeId,
        'tags': 'البيئة,تنظيف الشواطئ,التلوث البحري',
        'is_urgent': 0,
        'is_important': 1,
      },
    ];

    // Insert default tasks
    for (final task in defaultTasks) {
      await db.insert('tasks', task);
    }
  }

  // Helper method to convert List<String> to String for storage
  String? _listToString(List<String>? list) {
    if (list == null) return null;
    return list.join(',');
  }

  // Helper method to convert String to List<String> for retrieval
  List<String>? _stringToList(String? str) {
    if (str == null || str.isEmpty) return null;
    return str.split(',');
  }

  // Helper method to convert Map to String for storage
  String? _mapToString(Map<String, dynamic>? map) {
    if (map == null) return null;
    return map.toString();
  }

  // Helper method to parse Map from String for retrieval
  Map<String, dynamic>? _stringToMap(String? str) {
    if (str == null || str.isEmpty) return null;
    try {
      return json.decode(str);
    } catch (e) {
      return {};
    }
  }

  // CRUD Operations for Tasks

  // Insert a task
  Future<TaskModel> insertTask(TaskModel task) async {
    final db = await database;
    final uuid = const Uuid();
    final taskWithId = task.id == null
        ? TaskModel(
            id: uuid.v4(),
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            location: task.location,
            startTime: task.startTime,
            endTime: task.endTime,
            dueDate: task.dueDate,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            userId: task.userId,
            assignedTo: task.assignedTo,
            tags: task.tags,
            metadata: task.metadata,
            formData: task.formData,
            isUrgent: task.isUrgent,
            isImportant: task.isImportant,
          )
        : task;

    await db.insert(
      'tasks',
      {
        'id': taskWithId.id,
        'title': taskWithId.title,
        'description': taskWithId.description,
        'status': taskWithId.status,
        'priority': taskWithId.priority,
        'location': taskWithId.location,
        'start_time': taskWithId.startTime?.toIso8601String(),
        'end_time': taskWithId.endTime?.toIso8601String(),
        'due_date': taskWithId.dueDate?.toIso8601String(),
        'created_at': taskWithId.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'updated_at': taskWithId.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'user_id': taskWithId.userId,
        'assigned_to': taskWithId.assignedTo,
        'tags': _listToString(taskWithId.tags),
        'metadata': taskWithId.metadata != null ? json.encode(taskWithId.metadata) : null,
        'form_data': taskWithId.formData != null ? json.encode(taskWithId.formData) : null,
        'is_urgent': taskWithId.isUrgent ? 1 : 0,
        'is_important': taskWithId.isImportant ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return taskWithId;
  }

  // Update a task
  Future<TaskModel> updateTask(TaskModel task) async {
    final db = await database;
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      location: task.location,
      startTime: task.startTime,
      endTime: task.endTime,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
      userId: task.userId,
      assignedTo: task.assignedTo,
      tags: task.tags,
      metadata: task.metadata,
      formData: task.formData,
      isUrgent: task.isUrgent,
      isImportant: task.isImportant,
    );

    await db.update(
      'tasks',
      {
        'title': updatedTask.title,
        'description': updatedTask.description,
        'status': updatedTask.status,
        'priority': updatedTask.priority,
        'location': updatedTask.location,
        'start_time': updatedTask.startTime?.toIso8601String(),
        'end_time': updatedTask.endTime?.toIso8601String(),
        'due_date': updatedTask.dueDate?.toIso8601String(),
        'updated_at': updatedTask.updatedAt?.toIso8601String(),
        'user_id': updatedTask.userId,
        'assigned_to': updatedTask.assignedTo,
        'tags': _listToString(updatedTask.tags),
        'metadata': updatedTask.metadata != null ? json.encode(updatedTask.metadata) : null,
        'form_data': updatedTask.formData != null ? json.encode(updatedTask.formData) : null,
        'is_urgent': updatedTask.isUrgent ? 1 : 0,
        'is_important': updatedTask.isImportant ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [updatedTask.id],
    );

    return updatedTask;
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Get a task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapToTaskModel(maps.first);
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Get tasks by user ID
  Future<List<TaskModel>> getTasksByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Get tasks by assigned user
  Future<List<TaskModel>> getTasksByAssignedTo(String assignedTo) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'assigned_to = ?',
      whereArgs: [assignedTo],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Get tasks by priority
  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Get tasks by due date range
  Future<List<TaskModel>> getTasksByDueDate(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final String startDateStr = startDate.toIso8601String();
    final String endDateStr = endDate.toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'due_date >= ? AND due_date <= ?',
      whereArgs: [startDateStr, endDateStr],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => _mapToTaskModel(maps[i]));
  }

  // Helper method to convert database map to TaskModel
  TaskModel _mapToTaskModel(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      location: map['location'],
      startTime: map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      userId: map['user_id'],
      assignedTo: map['assigned_to'],
      tags: _stringToList(map['tags']),
      metadata: _stringToMap(map['metadata']),
      formData: _stringToMap(map['form_data']),
      isUrgent: map['is_urgent'] == 1,
      isImportant: map['is_important'] == 1,
    );
  }
}
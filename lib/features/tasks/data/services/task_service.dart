import 'package:webak/core/config/database_config.dart';
import 'package:webak/core/database/database_helper.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseConfig.instance.databaseHelper;

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    return await _databaseHelper.getAllTasks();
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    return await _databaseHelper.getTaskById(taskId);
  }

  // Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    return await _databaseHelper.insertTask(task);
  }

  // Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    return await _databaseHelper.updateTask(task);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _databaseHelper.deleteTask(taskId);
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    return await _databaseHelper.getTasksByStatus(status);
  }

  // Get tasks by priority
  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    return await _databaseHelper.getTasksByPriority(priority);
  }

  // Get tasks by due date range
  Future<List<TaskModel>> getTasksByDueDate(
      DateTime startDate, DateTime endDate) async {
    return await _databaseHelper.getTasksByDueDate(startDate, endDate);
  }

  // Get tasks by user ID
  Future<List<TaskModel>> getTasksByUserId(String userId) async {
    return await _databaseHelper.getTasksByUserId(userId);
  }

  // Get tasks by assigned user
  Future<List<TaskModel>> getTasksByAssignedTo(String assignedTo) async {
    return await _databaseHelper.getTasksByAssignedTo(assignedTo);
  }

  // Advanced search with multiple filters and pagination
  Future<List<TaskModel>> searchTasks({
    String? query,
    String? status,
    String? priority,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _databaseHelper.searchTasks(
      query: query,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
      startDate: startDate,
      endDate: endDate,
      tags: tags,
      limit: limit,
      offset: offset,
    );
  }

  // Get tasks count for pagination
  Future<int> getTasksCount({
    String? status,
    String? priority,
    String? assignedTo,
  }) async {
    return await _databaseHelper.getTasksCount(
      status: status,
      priority: priority,
      assignedTo: assignedTo,
    );
  }
}
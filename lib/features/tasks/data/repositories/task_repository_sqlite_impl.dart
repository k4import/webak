import 'dart:async';

import 'package:webak/core/config/database_config.dart';
import 'package:webak/features/tasks/data/services/task_service.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositorySQLiteImpl implements TaskRepository {
  final TaskService _taskService = TaskService();
  final StreamController<List<TaskModel>> _tasksStreamController =
      StreamController<List<TaskModel>>.broadcast();

  TaskRepositorySQLiteImpl() {
    // Initialize the stream with current tasks
    _refreshTasksStream();
  }

  // Helper method to refresh the tasks stream
  Future<void> _refreshTasksStream() async {
    final tasks = await getAllTasks();
    _tasksStreamController.add(tasks);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    // Get all tasks for employees to see all manager-created tasks
    // Only filter by user for specific cases if needed
    return await _taskService.getAllTasks();
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    return await _taskService.getTaskById(taskId);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final taskWithUserId = task.copyWith(userId: userId);
    final createdTask = await _taskService.createTask(taskWithUserId);
    await _refreshTasksStream();
    return createdTask;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Ensure the task belongs to the current user
    if (task.userId != null && task.userId != userId) {
      throw Exception('Cannot update task that belongs to another user');
    }
    
    final updatedTask = await _taskService.updateTask(task);
    await _refreshTasksStream();
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final userId = DatabaseConfig.instance.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Ensure the task belongs to the current user before deleting
    final task = await _taskService.getTaskById(taskId);
    if (task != null && task.userId != null && task.userId != userId) {
      throw Exception('Cannot delete task that belongs to another user');
    }
    
    await _taskService.deleteTask(taskId);
    await _refreshTasksStream();
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    return await _taskService.getTasksByStatus(status);
  }

  @override
  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    return await _taskService.getTasksByPriority(priority);
  }

  @override
  Future<List<TaskModel>> getTasksByDueDate(
      DateTime startDate, DateTime endDate) async {
    return await _taskService.getTasksByDueDate(startDate, endDate);
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    return await _taskService.getAllTasks();
  }

  @override
  Stream<List<TaskModel>> tasksStream() {
    return _tasksStreamController.stream;
  }

  // Clean up resources
  void dispose() {
    _tasksStreamController.close();
  }
}
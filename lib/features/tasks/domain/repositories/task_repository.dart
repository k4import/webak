import 'package:webak/features/tasks/domain/models/task_model.dart';

abstract class TaskRepository {
  /// Get all tasks for the current user
  Future<List<TaskModel>> getTasks();

  /// Get a specific task by ID
  Future<TaskModel?> getTaskById(String taskId);

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task);

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task);

  /// Delete a task by ID
  Future<void> deleteTask(String taskId);

  /// Get tasks filtered by status
  Future<List<TaskModel>> getTasksByStatus(String status);

  /// Get tasks filtered by priority
  Future<List<TaskModel>> getTasksByPriority(String priority);

  /// Get tasks filtered by due date range
  Future<List<TaskModel>> getTasksByDueDate(DateTime startDate, DateTime endDate);

  /// Get all tasks (for admins)
  Future<List<TaskModel>> getAllTasks();

  /// Stream of tasks for real-time updates
  Stream<List<TaskModel>> tasksStream();
}
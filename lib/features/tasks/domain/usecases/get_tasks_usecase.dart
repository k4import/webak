import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _taskRepository;

  GetTasksUseCase(this._taskRepository);

  Future<List<TaskModel>> call() async {
    return await _taskRepository.getTasks();
  }

  Future<List<TaskModel>> byStatus(String status) async {
    return await _taskRepository.getTasksByStatus(status);
  }

  Future<List<TaskModel>> byPriority(String priority) async {
    return await _taskRepository.getTasksByPriority(priority);
  }

  Future<List<TaskModel>> byDueDate(DateTime startDate, DateTime endDate) async {
    return await _taskRepository.getTasksByDueDate(startDate, endDate);
  }

  Future<List<TaskModel>> getAllTasks() async {
    return await _taskRepository.getAllTasks();
  }

  Stream<List<TaskModel>> stream() {
    return _taskRepository.tasksStream();
  }

  /// Advanced search with multiple filters and pagination - O(log n) with indexes
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
    return await _taskRepository.searchTasks(
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

  /// Get tasks count for pagination
  Future<int> getTasksCount({
    String? status,
    String? priority,
    String? assignedTo,
  }) async {
    return await _taskRepository.getTasksCount(
      status: status,
      priority: priority,
      assignedTo: assignedTo,
    );
  }
}
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
}
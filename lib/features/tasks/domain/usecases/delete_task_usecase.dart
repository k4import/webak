import 'package:webak/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _taskRepository;

  DeleteTaskUseCase(this._taskRepository);

  Future<void> call(String taskId) async {
    await _taskRepository.deleteTask(taskId);
  }
}
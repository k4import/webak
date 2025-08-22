import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository _taskRepository;

  CreateTaskUseCase(this._taskRepository);

  Future<TaskModel> call(TaskModel task) async {
    return await _taskRepository.createTask(task);
  }
}
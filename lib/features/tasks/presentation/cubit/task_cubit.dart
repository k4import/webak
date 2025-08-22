import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/features/tasks/domain/models/task_model.dart';
import 'package:webak/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/update_task_usecase.dart';

// Task States
abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;

  TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskCreated extends TaskState {
  final TaskModel task;

  TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskState {
  final TaskModel task;

  TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskState {
  final String taskId;

  TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// Task Cubit
class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  List<TaskModel> _tasks = [];
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 2);

  TaskCubit({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(TaskInitial());

  List<TaskModel> get tasks => _tasks;

  Future<void> loadTasks({bool forceRefresh = false}) async {
    // تحقق من الـ cache أولاً
    if (!forceRefresh && _lastLoadTime != null && _tasks.isNotEmpty) {
      final timeSinceLastLoad = DateTime.now().difference(_lastLoadTime!);
      if (timeSinceLastLoad < _cacheTimeout) {
        emit(TasksLoaded(_tasks));
        return;
      }
    }
    
    emit(TaskLoading());
    try {
      _tasks = await _getTasksUseCase();
      _lastLoadTime = DateTime.now();
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> loadAllTasks({bool forceRefresh = false}) async {
    // تحقق من الـ cache أولاً
    if (!forceRefresh && _lastLoadTime != null && _tasks.isNotEmpty) {
      final timeSinceLastLoad = DateTime.now().difference(_lastLoadTime!);
      if (timeSinceLastLoad < _cacheTimeout) {
        emit(TasksLoaded(_tasks));
        return;
      }
    }
    
    emit(TaskLoading());
    try {
      _tasks = await _getTasksUseCase.getAllTasks();
      _lastLoadTime = DateTime.now();
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> loadTasksByStatus(String status) async {
    emit(TaskLoading());
    try {
      _tasks = await _getTasksUseCase.byStatus(status);
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> loadTasksByPriority(String priority) async {
    emit(TaskLoading());
    try {
      _tasks = await _getTasksUseCase.byPriority(priority);
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> createTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      final createdTask = await _createTaskUseCase(task);
      _tasks = [createdTask, ..._tasks];
      emit(TaskCreated(createdTask));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      final updatedTask = await _updateTaskUseCase(task);
      _tasks = _tasks.map((t) => t.id == task.id ? updatedTask : t).toList();
      emit(TaskUpdated(updatedTask));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> deleteTask(String taskId) async {
    emit(TaskLoading());
    try {
      await _deleteTaskUseCase(taskId);
      _tasks = _tasks.where((task) => task.id != taskId).toList();
      emit(TaskDeleted(taskId));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
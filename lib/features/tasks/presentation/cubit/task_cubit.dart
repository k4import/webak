import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/utils/advanced_cache_manager.dart';
import 'package:webak/core/utils/search_algorithms.dart';
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

class TaskSearchResults extends TaskState {
  final List<TaskModel> results;
  final String query;
  final int totalCount;
  final bool hasMore;

  TaskSearchResults({
    required this.results,
    required this.query,
    required this.totalCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [results, query, totalCount, hasMore];
}

class TaskSuggestions extends TaskState {
  final List<String> suggestions;
  final String query;

  TaskSuggestions({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
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
      
      // Remove from search index and cache
      final taskToRemove = _tasks.firstWhere((t) => t.id == taskId, orElse: () => TaskModel.empty());
      if (taskToRemove.id.isNotEmpty) {
        SearchManager.instance.removeTask(taskToRemove.toMap());
        TaskCacheManager.clearAll(); // Clear cache to maintain consistency
      }
      
      emit(TaskDeleted(taskId));
      emit(TasksLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Advanced search with caching and efficient algorithms - O(log n + m)
  Future<void> searchTasks({
    String? query,
    String? status,
    String? priority,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    int limit = 50,
    int offset = 0,
    bool useCache = true,
  }) async {
    emit(TaskLoading());
    
    try {
      // Generate cache key
      String cacheKey = TaskCacheManager.generateQueryKey(
        status: status,
        priority: priority,
        assignedTo: assignedTo,
        limit: limit,
        offset: offset,
      );
      
      // Check cache first - O(1)
      if (useCache) {
        final cachedResults = TaskCacheManager.getCachedQuery(cacheKey);
        if (cachedResults != null) {
          final tasks = cachedResults.map((map) => TaskModel.fromMap(map)).toList();
          emit(TaskSearchResults(
            results: tasks,
            query: query ?? '',
            totalCount: tasks.length,
            hasMore: tasks.length >= limit,
          ));
          return;
        }
      }
      
      // If using text search, use advanced search engine - O(m)
      if (query != null && query.isNotEmpty) {
        // Ensure search index is populated
        await _ensureSearchIndexPopulated();
        
        // Use advanced search engine
        Set<String> matchingIds = SearchManager.instance.search(
          query: query,
          status: status,
          priority: priority,
          assignedTo: assignedTo,
        );
        
        // Filter tasks by matching IDs
        List<TaskModel> results = _tasks
            .where((task) => matchingIds.contains(task.id))
            .toList();
        
        // Apply date filters
        if (startDate != null || endDate != null) {
          results = results.where((task) {
            if (task.dueDate == null) return false;
            
            if (startDate != null && task.dueDate!.isBefore(startDate)) {
              return false;
            }
            
            if (endDate != null && task.dueDate!.isAfter(endDate)) {
              return false;
            }
            
            return true;
          }).toList();
        }
        
        // Apply pagination
        int totalCount = results.length;
        results = results.skip(offset).take(limit).toList();
        
        // Cache results
        if (useCache) {
          TaskCacheManager.cacheQuery(cacheKey, results.map((t) => t.toMap()).toList());
        }
        
        emit(TaskSearchResults(
          results: results,
          query: query,
          totalCount: totalCount,
          hasMore: offset + results.length < totalCount,
        ));
      } else {
        // Use database search for non-text queries - O(log n) with indexes
        final searchResults = await _getTasksUseCase.searchTasks(
          status: status,
          priority: priority,
          assignedTo: assignedTo,
          startDate: startDate,
          endDate: endDate,
          tags: tags,
          limit: limit,
          offset: offset,
        );
        
        // Cache results
        if (useCache) {
          TaskCacheManager.cacheQuery(cacheKey, searchResults.map((t) => t.toMap()).toList());
        }
        
        emit(TaskSearchResults(
          results: searchResults,
          query: query ?? '',
          totalCount: searchResults.length,
          hasMore: searchResults.length >= limit,
        ));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  /// Get search suggestions - O(m + k) where k is number of suggestions
  Future<void> getSearchSuggestions(String query, {int maxSuggestions = 10}) async {
    if (query.length < 2) {
      emit(TaskSuggestions(suggestions: [], query: query));
      return;
    }
    
    try {
      await _ensureSearchIndexPopulated();
      
      final suggestions = SearchManager.instance.getSuggestions(
        query,
        maxSuggestions: maxSuggestions,
      );
      
      emit(TaskSuggestions(suggestions: suggestions, query: query));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  /// Ensure search index is populated - O(n*m) where n is tasks, m is avg text length
  Future<void> _ensureSearchIndexPopulated() async {
    if (_tasks.isEmpty) {
      await loadTasks();
    }
    
    // Index all tasks for searching
    for (final task in _tasks) {
      SearchManager.instance.indexTask(task.toMap());
    }
  }
  
  /// Clear all caches and search indices
  void clearCaches() {
    TaskCacheManager.clearAll();
    SearchManager.instance.clear();
    _lastLoadTime = null;
  }
  
  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    return {
      'cacheStats': TaskCacheManager.getStats(),
      'searchStats': SearchManager.instance.getStats(),
      'tasksCount': _tasks.length,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'cacheTimeout': _cacheTimeout.inMinutes,
    };
  }
}
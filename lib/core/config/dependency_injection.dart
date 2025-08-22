
import 'package:get_it/get_it.dart';
import 'package:webak/core/theme/theme_cubit.dart';
import 'package:webak/features/auth/data/repositories/auth_repository_sqlite_impl.dart';
import 'package:webak/features/auth/domain/repositories/auth_repository.dart';
import 'package:webak/features/auth/domain/usecases/login_usecase.dart';
import 'package:webak/features/auth/domain/usecases/logout_usecase.dart';
import 'package:webak/features/auth/domain/usecases/register_usecase.dart';
import 'package:webak/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:webak/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:webak/features/tasks/data/repositories/task_repository_sqlite_impl.dart';
import 'package:webak/features/tasks/domain/repositories/task_repository.dart';
import 'package:webak/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:webak/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:webak/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:webak/features/reports/data/repositories/report_repository_sqlite_impl.dart';
import 'package:webak/features/reports/domain/repositories/report_repository.dart';
import 'package:webak/features/reports/domain/usecases/create_report_usecase.dart';

import 'package:webak/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:webak/features/reports/domain/usecases/update_report_usecase.dart';
import 'package:webak/features/reports/domain/usecases/delete_report_usecase.dart';
import 'package:webak/features/reports/presentation/cubit/report_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Cubits / BLoCs
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  sl.registerFactory(() => TaskCubit(
        getTasksUseCase: sl(),
        createTaskUseCase: sl(),
        updateTaskUseCase: sl(),
        deleteTaskUseCase: sl(),
      ));

  sl.registerFactory(() => ReportCubit(
         createReportUseCase: sl(),
         updateReportUseCase: sl(),
         deleteReportUseCase: sl(),
         getReportsUseCase: sl(),
       ));
      
  sl.registerFactory(() => ThemeCubit());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositorySQLiteImpl());
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositorySQLiteImpl());
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositorySQLiteImpl());

  // Use Cases
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Tasks
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // Reports
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));
  
  sl.registerLazySingleton(() => GetReportsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReportUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReportUseCase(sl()));
}
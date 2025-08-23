import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webak/core/utils/cache_helper.dart';
import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:webak/features/auth/domain/usecases/login_usecase.dart';
import 'package:webak/features/auth/domain/usecases/logout_usecase.dart';
import 'package:webak/features/auth/domain/usecases/register_usecase.dart';

// Auth States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })
      : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      // تحقق من الـ cache أولاً
      if (CacheHelper.isLoggedIn()) {
        final userId = CacheHelper.getUserId();
        final email = CacheHelper.getUserEmail();
        final role = CacheHelper.getUserRole();
        
        if (userId != null && email != null && role != null) {
          // إنشاء user من البيانات المحفوظة
          final cachedUser = UserModel(
            id: userId,
            email: email,
            role: role,
            username: email.split('@')[0], // استخدام الجزء الأول من الإيميل كـ username
            fullName: CacheHelper.getUserData()?['full_name'] ?? '',
            avatarUrl: CacheHelper.getUserData()?['avatar_url'],
            lastSignInAt: CacheHelper.getLoginTime(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          emit(AuthAuthenticated(cachedUser));
          return;
        }
      }
      
      // إذا لم توجد بيانات محفوظة، تحقق من قاعدة البيانات
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        // حفظ بيانات المستخدم في الـ cache
         await CacheHelper.saveUserLogin(
           userId: user.id,
           email: user.email,
           role: user.role ?? 'employee',
           userData: {
             'full_name': user.fullName ?? '',
             'avatar_url': user.avatarUrl,
             'username': user.username ?? '',
           },
         );
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        email: email,
        password: password,
      );
      
      // حفظ بيانات المستخدم في الـ cache
       await CacheHelper.saveUserLogin(
         userId: user.id,
         email: user.email,
         role: user.role ?? 'employee',
         userData: {
           'full_name': user.fullName ?? '',
           'avatar_url': user.avatarUrl,
           'username': user.username ?? '',
         },
       );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? username,
    String? role,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _registerUseCase(
        email: email,
        password: password,
        username: username,
        metadata: {'role': role ?? 'employee'},
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
      
      // مسح بيانات الـ cache
      await CacheHelper.clearUserLogin();
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<UserModel> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signIn(
      email: email,
      password: password,
    );
  }
}
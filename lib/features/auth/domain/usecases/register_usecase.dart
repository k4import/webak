import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<UserModel> call({
    required String email,
    required String password,
    String? username,
    Map<String, dynamic>? metadata,
  }) async {
    return await _authRepository.signUp(
      email: email,
      password: password,
      username: username,
      metadata: metadata,
    );
  }
}
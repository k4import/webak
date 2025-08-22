import 'package:webak/features/auth/domain/models/user_model.dart';
import 'package:webak/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<UserModel?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
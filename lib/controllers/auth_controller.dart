import '../repositories/auth_repository.dart';

class AuthController {
  final AuthRepository authRepository;

  AuthController({AuthRepository? authRepository})
    : authRepository = authRepository ?? AuthRepository();

  Future<bool> loginUser(String email, String password) async {
    return await authRepository.loginUser(email, password);
  }

  Future<bool> registerUser(String name, String email, String password) async {
    return await authRepository.registerUser(name, email, password);
  }

  Future<void> claimLegacyData(String email) async {
    await authRepository.claimLegacyData(email);
  }
}

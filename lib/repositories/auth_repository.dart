import '../dao/user_dao.dart';
import '../database/db_helper.dart';
import '../utils/password_hasher.dart';

class AuthRepository {
  final UserDao userDao;

  AuthRepository({UserDao? userDao}) : userDao = userDao ?? UserDao();

  Future<bool> loginUser(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await userDao.findByEmail(normalizedEmail);

    if (user == null) return false;

    final storedPassword = user['password'] as String? ?? '';
    final isValidPassword = PasswordHasher.verifyPassword(
      password,
      storedPassword,
    );

    if (isValidPassword && PasswordHasher.needsUpgrade(storedPassword)) {
      await userDao.updatePassword(
        user['id'] as int,
        PasswordHasher.hashPassword(password),
      );
    }

    return isValidPassword;
  }

  Future<bool> registerUser(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingUser = await userDao.findByEmail(normalizedEmail);

    if (existingUser != null) {
      return false;
    }

    await userDao.insertUser(
      name: name,
      email: normalizedEmail,
      password: PasswordHasher.hashPassword(password),
    );

    return true;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await userDao.findByEmail(normalizedEmail);

    if (user == null) return false;

    await userDao.updatePassword(
      user['id'] as int,
      PasswordHasher.hashPassword(newPassword),
    );

    return true;
  }

  Future<void> claimLegacyData(String email) async {
    await DBHelper.claimLegacyData(email);
  }
}

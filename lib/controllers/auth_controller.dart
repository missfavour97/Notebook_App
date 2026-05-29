import '../database/db_helper.dart';
import '../utils/password_hasher.dart';

class AuthController {
  Future<bool> loginUser(String email, String password) async {
    final db = await DBHelper.initDb();

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) return false;

    final user = result.first;
    final storedPassword = user['password'] as String? ?? '';
    final isValidPassword = PasswordHasher.verifyPassword(
      password,
      storedPassword,
    );

    if (isValidPassword && PasswordHasher.needsUpgrade(storedPassword)) {
      await db.update(
        'users',
        {'password': PasswordHasher.hashPassword(password)},
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    }

    return isValidPassword;
  }

  Future<bool> registerUser(String name, String email, String password) async {
    final db = await DBHelper.initDb();

    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      return false;
    }

    await db.insert('users', {
      'name': name,
      'email': email,
      'password': PasswordHasher.hashPassword(password),
    });

    return true;
  }
}

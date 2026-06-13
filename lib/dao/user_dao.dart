import '../database/db_helper.dart';

class UserDao {
  Future<Map<String, dynamic>?> findByEmail(String email) async {
    final db = await DBHelper.initDb();
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<int> insertUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await DBHelper.initDb();

    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> updatePassword(int id, String password) async {
    final db = await DBHelper.initDb();

    await db.update(
      'users',
      {'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

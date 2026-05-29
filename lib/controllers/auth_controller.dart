import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class AuthController {

  Future<bool> loginUser(
      String email,
      String password,
      ) async {

    final Database db = await DBHelper.initDb();

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [
        email,
        password,
      ],
    );

    return result.isNotEmpty;
  }

  Future<bool> registerUser(
      String name,
      String email,
      String password,
      ) async {

    final Database db = await DBHelper.initDb();

    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      return false;
    }

    await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return true;
  }
}
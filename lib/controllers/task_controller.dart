import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class TaskController {

  Future<List<Map<String, dynamic>>> loadTasks(
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    return await db.query(
      'tasks',
      where: 'field = ?',
      whereArgs: [field],
      orderBy: 'id DESC',
    );
  }

  Future<void> addTask(
      String title,
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    await db.insert(
      'tasks',
      {
        'title': title,
        'isCompleted': 0,
        'field': field,
      },
    );
  }

  Future<void> toggleTask(
      int id,
      bool isCompleted,
      ) async {

    final Database db = await DBHelper.initDb();

    await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {

    final Database db = await DBHelper.initDb();

    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
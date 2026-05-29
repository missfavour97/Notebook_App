import '../database/db_helper.dart';

class TaskController {
  Future<List<Map<String, dynamic>>> loadTasks(String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return [];

    return await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<void> addTask(String title, String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.insert('tasks', {
      'title': title,
      'isCompleted': 0,
      'field': field,
      'userEmail': userEmail,
    });
  }

  Future<void> toggleTask(int id, bool isCompleted) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.delete(
      'tasks',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

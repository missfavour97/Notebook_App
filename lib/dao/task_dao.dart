import '../database/db_helper.dart';

class TaskDao {
  Future<List<Map<String, dynamic>>> findByField({
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchByTitle({
    required String field,
    required String userEmail,
    required String query,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ? AND title LIKE ?',
      whereArgs: [field, userEmail, '%$query%'],
    );
  }

  Future<int> countByField({
    required String field,
    required String userEmail,
  }) async {
    final rows = await findByField(field: field, userEmail: userEmail);
    return rows.length;
  }

  Future<void> insertTask({
    required String title,
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.insert('tasks', {
      'title': title,
      'isCompleted': 0,
      'field': field,
      'userEmail': userEmail,
    });
  }

  Future<void> updateCompletion({
    required int id,
    required bool isCompleted,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<void> deleteTask({required int id, required String userEmail}) async {
    final db = await DBHelper.initDb();

    await db.delete(
      'tasks',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

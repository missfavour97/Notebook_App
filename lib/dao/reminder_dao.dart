import '../database/db_helper.dart';

class ReminderDao {
  Future<List<Map<String, dynamic>>> findByField({
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'reminders',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'reminderDate ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchByTitle({
    required String field,
    required String userEmail,
    required String query,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'reminders',
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

  Future<void> insertReminder({
    required String title,
    required String reminderDate,
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.insert('reminders', {
      'title': title,
      'reminderDate': reminderDate,
      'field': field,
      'userEmail': userEmail,
    });
  }

  Future<void> deleteReminder({
    required int id,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.delete(
      'reminders',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

import '../database/db_helper.dart';

class ReminderController {
  Future<List<Map<String, dynamic>>> loadReminders(String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return [];

    return await db.query(
      'reminders',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'reminderDate ASC',
    );
  }

  Future<void> addReminder(
    String title,
    String reminderDate,
    String field,
  ) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.insert('reminders', {
      'title': title,
      'reminderDate': reminderDate,
      'field': field,
      'userEmail': userEmail,
    });
  }

  Future<void> deleteReminder(int id) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.delete(
      'reminders',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

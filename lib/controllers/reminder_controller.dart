import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class ReminderController {

  Future<List<Map<String, dynamic>>> loadReminders(
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    return await db.query(
      'reminders',
      where: 'field = ?',
      whereArgs: [field],
      orderBy: 'reminderDate ASC',
    );
  }

  Future<void> addReminder(
      String title,
      String reminderDate,
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    await db.insert(
      'reminders',
      {
        'title': title,
        'reminderDate': reminderDate,
        'field': field,
      },
    );
  }

  Future<void> deleteReminder(int id) async {

    final Database db = await DBHelper.initDb();

    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
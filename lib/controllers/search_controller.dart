import '../database/db_helper.dart';

class AppSearchController {
  Future<List<Map<String, dynamic>>> searchAll(
    String query,
    String field,
  ) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (query.trim().isEmpty || userEmail == null) {
      return [];
    }

    final subjects = await db.query(
      'subjects',
      where: 'field = ? AND userEmail = ? AND title LIKE ?',
      whereArgs: [field, userEmail, '%$query%'],
    );

    final notes = await db.query(
      'notes',
      where: 'field = ? AND userEmail = ? AND content LIKE ?',
      whereArgs: [field, userEmail, '%$query%'],
    );

    final tasks = await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ? AND title LIKE ?',
      whereArgs: [field, userEmail, '%$query%'],
    );

    final reminders = await db.query(
      'reminders',
      where: 'field = ? AND userEmail = ? AND title LIKE ?',
      whereArgs: [field, userEmail, '%$query%'],
    );

    return [
      ...subjects.map(
        (item) => {
          'type': 'Subject',
          'title': item['title'],
          'subtitle': field,
        },
      ),
      ...notes.map(
        (item) => {
          'type': 'Note',
          'title': item['subject'],
          'subtitle': item['content'],
        },
      ),
      ...tasks.map(
        (item) => {
          'type': 'Task',
          'title': item['title'],
          'subtitle': item['isCompleted'] == 1 ? 'Completed' : 'Pending',
        },
      ),
      ...reminders.map(
        (item) => {
          'type': 'Reminder',
          'title': item['title'],
          'subtitle': item['reminderDate'],
        },
      ),
    ];
  }
}

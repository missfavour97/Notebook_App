import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_notebook/database/db_helper_web.dart';

void main() {
  test('stores and filters rows in the web database adapter', () async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    final db = WebAppDatabase(prefs);

    await db.insert('tasks', {
      'title': 'Read chapter one',
      'isCompleted': 0,
      'field': 'Basic',
      'userEmail': 'student@example.com',
    });

    await db.insert('tasks', {
      'title': 'Hidden task',
      'isCompleted': 0,
      'field': 'Basic',
      'userEmail': 'other@example.com',
    });

    final rows = await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ? AND title LIKE ?',
      whereArgs: ['Basic', 'student@example.com', '%chapter%'],
    );

    expect(rows, hasLength(1));
    expect(rows.first['title'], 'Read chapter one');
  });

  test('claims legacy rows for the current web user', () async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    final db = WebAppDatabase(prefs);

    await db.insert('subjects', {
      'title': 'Biology',
      'field': 'Basic',
      'userEmail': '',
    });

    await DBHelper.claimLegacyData('student@example.com');

    final rows = await db.query(
      'subjects',
      where: 'field = ? AND userEmail = ?',
      whereArgs: ['Basic', 'student@example.com'],
    );

    expect(rows, hasLength(1));
    expect(rows.first['title'], 'Biology');
  });
}

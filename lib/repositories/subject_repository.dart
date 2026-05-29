import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class SubjectRepository {
  Future<List<Map<String, dynamic>>> getSubjects(String field) async {
    final Database db = await DBHelper.initDb();

    return await db.query(
      'subjects',
      where: 'field = ?',
      whereArgs: [field],
      orderBy: 'id DESC',
    );
  }

  Future<void> addSubject(String title, String field) async {
    final Database db = await DBHelper.initDb();

    await db.insert(
      'subjects',
      {
        'title': title,
        'field': field,
      },
    );
  }

  Future<void> updateSubject(int id, String newTitle) async {
    final Database db = await DBHelper.initDb();

    await db.update(
      'subjects',
      {
        'title': newTitle,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSubject(int id) async {
    final Database db = await DBHelper.initDb();

    await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
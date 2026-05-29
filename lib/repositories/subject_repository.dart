import '../database/db_helper.dart';

class SubjectRepository {
  Future<List<Map<String, dynamic>>> getSubjects(String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return [];

    return await db.query(
      'subjects',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<void> addSubject(
    String title,
    String field, {
    int? coverColor,
    String? coverPattern,
  }) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.insert('subjects', {
      'title': title,
      'field': field,
      'userEmail': userEmail,
      'coverColor': coverColor,
      'coverPattern': coverPattern,
    });
  }

  Future<void> updateSubject(
    int id,
    String newTitle, {
    int? coverColor,
    String? coverPattern,
  }) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.update(
      'subjects',
      {
        'title': newTitle,
        'coverColor': coverColor,
        'coverPattern': coverPattern,
      },
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<void> deleteSubject(int id) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.delete(
      'subjects',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

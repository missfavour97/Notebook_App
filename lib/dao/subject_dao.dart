import '../database/db_helper.dart';

class SubjectDao {
  Future<List<Map<String, dynamic>>> findByField({
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'subjects',
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
      'subjects',
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

  Future<void> insertSubject({
    required String title,
    required String field,
    required String userEmail,
    int? coverColor,
    String? coverPattern,
  }) async {
    final db = await DBHelper.initDb();

    await db.insert('subjects', {
      'title': title,
      'field': field,
      'userEmail': userEmail,
      'coverColor': coverColor,
      'coverPattern': coverPattern,
    });
  }

  Future<void> updateSubject({
    required int id,
    required String userEmail,
    required Map<String, Object?> values,
  }) async {
    final db = await DBHelper.initDb();

    await db.update(
      'subjects',
      values,
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<void> deleteSubject({
    required int id,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.delete(
      'subjects',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }
}

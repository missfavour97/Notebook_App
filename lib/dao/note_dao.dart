import '../database/db_helper.dart';

class NoteDao {
  Future<Map<String, dynamic>?> findBySubjectAndField({
    required String subject,
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();
    final rows = await db.query(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<List<Map<String, dynamic>>> findByField({
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'notes',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchByContent({
    required String field,
    required String userEmail,
    required String query,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'notes',
      where: 'field = ? AND userEmail = ? AND content LIKE ?',
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

  Future<void> upsertNote({
    required String subject,
    required String field,
    required String content,
    required String noteType,
    required String drawing,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();
    final existing = await findBySubjectAndField(
      subject: subject,
      field: field,
      userEmail: userEmail,
    );
    final data = {
      'subject': subject,
      'field': field,
      'content': content,
      'noteType': noteType,
      'drawing': drawing,
      'userEmail': userEmail,
    };

    if (existing != null) {
      await db.update(
        'notes',
        data,
        where: 'subject = ? AND field = ? AND userEmail = ?',
        whereArgs: [subject, field, userEmail],
      );
    } else {
      await db.insert('notes', data);
    }
  }

  Future<void> deleteNote({
    required String subject,
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.delete(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
    );
  }
}

import '../database/db_helper.dart';

class NoteDao {
  Future<Map<String, dynamic>?> findById({
    required int id,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();
    final rows = await db.query(
      'notes',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<Map<String, dynamic>?> findBySubjectAndField({
    required String subject,
    required String field,
    required String userEmail,
  }) async {
    final rows = await findBySubject(
      subject: subject,
      field: field,
      userEmail: userEmail,
    );

    if (rows.isEmpty) return null;

    return rows.first;
  }

  Future<List<Map<String, dynamic>>> findBySubject({
    required String subject,
    required String field,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    return await db.query(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
      orderBy: 'updatedAt DESC',
    );
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
      orderBy: 'updatedAt DESC',
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

  Future<int> insertNote({
    required String title,
    required String subject,
    required String field,
    required String content,
    required String noteType,
    required String drawing,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();
    final now = DateTime.now().toIso8601String();

    return await db.insert('notes', {
      'title': title,
      'subject': subject,
      'field': field,
      'content': content,
      'noteType': noteType,
      'drawing': drawing,
      'userEmail': userEmail,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
    required String noteType,
    required String drawing,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.update(
      'notes',
      {
        'title': title,
        'content': content,
        'noteType': noteType,
        'drawing': drawing,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  Future<int> upsertNote({
    int? id,
    String? title,
    required String subject,
    required String field,
    required String content,
    required String noteType,
    required String drawing,
    required String userEmail,
  }) async {
    if (id != null) {
      await updateNote(
        id: id,
        title: title ?? defaultTitle(noteType),
        content: content,
        noteType: noteType,
        drawing: drawing,
        userEmail: userEmail,
      );
      return id;
    }

    return await insertNote(
      title: title ?? defaultTitle(noteType),
      subject: subject,
      field: field,
      content: content,
      noteType: noteType,
      drawing: drawing,
      userEmail: userEmail,
    );
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

  Future<void> deleteNoteById({
    required int id,
    required String userEmail,
  }) async {
    final db = await DBHelper.initDb();

    await db.delete(
      'notes',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userEmail],
    );
  }

  String defaultTitle(String noteType) {
    return noteType.trim().isEmpty ? 'Untitled Note' : noteType;
  }
}

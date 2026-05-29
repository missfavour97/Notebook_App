import '../database/db_helper.dart';

class NoteController {
  Future<Map<String, dynamic>?> loadNote(String subject, String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return null;

    final result = await db.query(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> loadNotes(String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return [];

    return await db.query(
      'notes',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [field, userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<void> saveNote(
    String subject,
    String field,
    String content,
    String noteType,
    String drawing,
  ) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    final existing = await db.query(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
      limit: 1,
    );

    final data = {
      'subject': subject,
      'field': field,
      'content': content,
      'noteType': noteType,
      'drawing': drawing,
      'userEmail': userEmail,
    };

    if (existing.isNotEmpty) {
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

  Future<void> deleteNote(String subject, String field) async {
    final db = await DBHelper.initDb();
    final userEmail = await DBHelper.currentUserEmail();

    if (userEmail == null) return;

    await db.delete(
      'notes',
      where: 'subject = ? AND field = ? AND userEmail = ?',
      whereArgs: [subject, field, userEmail],
    );
  }
}

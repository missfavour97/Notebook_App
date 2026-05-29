import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class NoteController {

  Future<Map<String, dynamic>?> loadNote(
      String subject,
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    final result = await db.query(
      'notes',
      where: 'subject = ? AND field = ?',
      whereArgs: [
        subject,
        field,
      ],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> saveNote(
      String subject,
      String field,
      String content,
      String noteType,
      String drawing,
      ) async {

    final Database db = await DBHelper.initDb();

    final existing = await db.query(
      'notes',
      where: 'subject = ? AND field = ?',
      whereArgs: [
        subject,
        field,
      ],
      limit: 1,
    );

    final data = {
      'subject': subject,
      'field': field,
      'content': content,
      'noteType': noteType,
      'drawing': drawing,
    };

    if (existing.isNotEmpty) {
      await db.update(
        'notes',
        data,
        where: 'subject = ? AND field = ?',
        whereArgs: [
          subject,
          field,
        ],
      );
    } else {
      await db.insert(
        'notes',
        data,
      );
    }
  }

  Future<void> deleteNote(
      String subject,
      String field,
      ) async {

    final Database db = await DBHelper.initDb();

    await db.delete(
      'notes',
      where: 'subject = ? AND field = ?',
      whereArgs: [
        subject,
        field,
      ],
    );
  }
}
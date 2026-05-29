mport 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> initDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'notebook.db'),
      version: 8,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE subjects(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            field TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            field TEXT,
            content TEXT,
            noteType TEXT,
            drawing TEXT,
            UNIQUE(subject, field)
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER,
            field TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            reminderDate TEXT,
            field TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _fixNotesTable(db);
        await _fixTasksTable(db);
        await _fixRemindersTable(db);
      },
      onOpen: (db) async {
        await _fixNotesTable(db);
        await _fixTasksTable(db);
        await _fixRemindersTable(db);
      },
    );
  }

  static Future<void> _fixNotesTable(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='notes'",
    );

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT,
          field TEXT,
          content TEXT,
          noteType TEXT,
          drawing TEXT,
          UNIQUE(subject, field)
        )
      ''');
      return;
    }

    final columns = await db.rawQuery("PRAGMA table_info(notes)");
    final columnNames = columns.map((c) => c['name']).toList();

    if (!columnNames.contains('field')) {
      await db.execute("ALTER TABLE notes ADD COLUMN field TEXT");
    }

    if (!columnNames.contains('drawing')) {
      await db.execute("ALTER TABLE notes ADD COLUMN drawing TEXT");
    }

    if (!columnNames.contains('noteType')) {
      await db.execute("ALTER TABLE notes ADD COLUMN noteType TEXT");
    }

    if (!columnNames.contains('content')) {
      await db.execute("ALTER TABLE notes ADD COLUMN content TEXT");
    }
  }

  static Future<void> _fixTasksTable(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'",
    );

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          isCompleted INTEGER,
          field TEXT
        )
      ''');
    }
  }

  static Future<void> _fixRemindersTable(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reminders'",
    );

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          reminderDate TEXT,
          field TEXT
        )
      ''');
    }
  }
}
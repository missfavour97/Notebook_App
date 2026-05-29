import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class DBHelper {
  static const String _subjectsTable = 'subjects';
  static const String _notesTable = 'notes';
  static const String _tasksTable = 'tasks';
  static const String _remindersTable = 'reminders';
  static const List<String> _userScopedTables = [
    _subjectsTable,
    _notesTable,
    _tasksTable,
    _remindersTable,
  ];

  static Future<AppDatabase> initDb() async {
    final db = await _openDb();
    return SqfliteAppDatabase(db);
  }

  static Future<Database> _openDb() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'notebook.db'),
      version: 9,
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
            field TEXT,
            userEmail TEXT
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
            userEmail TEXT,
            UNIQUE(subject, field, userEmail)
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER,
            field TEXT,
            userEmail TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            reminderDate TEXT,
            field TEXT,
            userEmail TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _fixSubjectsTable(db);
        await _fixNotesTable(db);
        await _fixTasksTable(db);
        await _fixRemindersTable(db);
      },
      onOpen: (db) async {
        await _fixSubjectsTable(db);
        await _fixNotesTable(db);
        await _fixTasksTable(db);
        await _fixRemindersTable(db);
      },
    );
  }

  static Future<String?> currentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<void> claimLegacyData(String email) async {
    if (email.trim().isEmpty) return;

    final db = await initDb();

    for (final table in _userScopedTables) {
      await db.update(
        table,
        {'userEmail': email},
        where: 'userEmail IS NULL OR userEmail = ?',
        whereArgs: [''],
      );
    }
  }

  static Future<void> _fixSubjectsTable(Database db) async {
    final exists = await _tableExists(db, _subjectsTable);

    if (!exists) {
      await db.execute('''
        CREATE TABLE subjects(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          field TEXT,
          userEmail TEXT
        )
      ''');
      return;
    }

    await _addColumnIfMissing(db, _subjectsTable, 'userEmail TEXT');
  }

  static Future<void> _fixNotesTable(Database db) async {
    final exists = await _tableExists(db, _notesTable);

    if (!exists) {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT,
          field TEXT,
          content TEXT,
          noteType TEXT,
          drawing TEXT,
          userEmail TEXT,
          UNIQUE(subject, field, userEmail)
        )
      ''');
      return;
    }

    await _addColumnIfMissing(db, _notesTable, 'field TEXT');
    await _addColumnIfMissing(db, _notesTable, 'drawing TEXT');
    await _addColumnIfMissing(db, _notesTable, 'noteType TEXT');
    await _addColumnIfMissing(db, _notesTable, 'content TEXT');
    await _addColumnIfMissing(db, _notesTable, 'userEmail TEXT');

    final createSql = await _createSql(db, _notesTable);
    final normalizedSql = (createSql ?? '').toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    final hasUserScopedUnique = normalizedSql.contains(
      'unique(subject,field,useremail)',
    );

    if (!hasUserScopedUnique) {
      await _rebuildNotesTable(db);
    }
  }

  static Future<void> _fixTasksTable(Database db) async {
    final exists = await _tableExists(db, _tasksTable);

    if (!exists) {
      await db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          isCompleted INTEGER,
          field TEXT,
          userEmail TEXT
        )
      ''');
      return;
    }

    await _addColumnIfMissing(db, _tasksTable, 'userEmail TEXT');
  }

  static Future<void> _fixRemindersTable(Database db) async {
    final exists = await _tableExists(db, _remindersTable);

    if (!exists) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          reminderDate TEXT,
          field TEXT,
          userEmail TEXT
        )
      ''');
      return;
    }

    await _addColumnIfMissing(db, _remindersTable, 'userEmail TEXT');
  }

  static Future<bool> _tableExists(Database db, String tableName) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    return tables.isNotEmpty;
  }

  static Future<String?> _createSql(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    if (result.isEmpty) return null;

    return result.first['sql'] as String?;
  }

  static Future<List<String>> _columnNames(
    Database db,
    String tableName,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    return columns.map((column) => column['name'].toString()).toList();
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String tableName,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final columns = await _columnNames(db, tableName);

    if (!columns.contains(columnName)) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnDefinition');
    }
  }

  static Future<void> _rebuildNotesTable(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS notes_migration');
      await txn.execute('''
        CREATE TABLE notes_migration(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT,
          field TEXT,
          content TEXT,
          noteType TEXT,
          drawing TEXT,
          userEmail TEXT,
          UNIQUE(subject, field, userEmail)
        )
      ''');

      await txn.execute('''
        INSERT OR IGNORE INTO notes_migration(
          id,
          subject,
          field,
          content,
          noteType,
          drawing,
          userEmail
        )
        SELECT
          id,
          subject,
          field,
          content,
          noteType,
          drawing,
          userEmail
        FROM notes
      ''');

      await txn.execute('DROP TABLE notes');
      await txn.execute('ALTER TABLE notes_migration RENAME TO notes');
    });
  }
}

class SqfliteAppDatabase implements AppDatabase {
  final Database _db;

  SqfliteAppDatabase(this._db);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = await _db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    return await _db.insert(table, values);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _db.delete(table, where: where, whereArgs: whereArgs);
  }
}

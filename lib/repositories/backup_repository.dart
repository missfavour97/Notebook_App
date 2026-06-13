import 'dart:convert';

import '../database/app_database.dart';
import '../database/db_helper.dart';
import 'current_user_scope.dart';

class NotebookBackup {
  final String field;
  final String userEmail;
  final DateTime exportedAt;
  final Map<String, List<Map<String, dynamic>>> tables;

  const NotebookBackup({
    required this.field,
    required this.userEmail,
    required this.exportedAt,
    required this.tables,
  });

  int get subjectCount => tables['subjects']?.length ?? 0;
  int get noteCount => tables['notes']?.length ?? 0;
  int get taskCount => tables['tasks']?.length ?? 0;
  int get reminderCount => tables['reminders']?.length ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'app': 'My Notebook',
      'field': field,
      'userEmail': userEmail,
      'exportedAt': exportedAt.toIso8601String(),
      'data': tables,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

class BackupRepository {
  static const List<String> _tables = [
    'subjects',
    'notes',
    'tasks',
    'reminders',
  ];

  final AppDatabase? database;
  final CurrentUserScope userScope;
  final DateTime Function() now;

  BackupRepository({
    this.database,
    CurrentUserScope? userScope,
    DateTime Function()? now,
  }) : userScope = userScope ?? CurrentUserScope(),
       now = now ?? DateTime.now;

  Future<NotebookBackup?> exportField(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null || userEmail.isEmpty) return null;

    final db = database ?? await DBHelper.initDb();
    final exportedTables = <String, List<Map<String, dynamic>>>{};

    for (final table in _tables) {
      exportedTables[table] = await db.query(
        table,
        where: 'field = ? AND userEmail = ?',
        whereArgs: [field, userEmail],
        orderBy: table == 'reminders' ? 'reminderDate ASC' : 'id DESC',
      );
    }

    return NotebookBackup(
      field: field,
      userEmail: userEmail,
      exportedAt: now(),
      tables: exportedTables,
    );
  }
}

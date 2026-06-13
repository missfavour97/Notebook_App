import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_notebook/database/app_database.dart';
import 'package:my_notebook/repositories/backup_repository.dart';
import 'package:my_notebook/repositories/current_user_scope.dart';

void main() {
  test('exports only the active user and selected field', () async {
    final database = _FakeDatabase({
      'users': [
        {
          'id': 1,
          'email': 'student@example.com',
          'password': 'hashed-password',
        },
      ],
      'subjects': [
        {
          'id': 1,
          'title': 'Algorithms',
          'field': 'Computer Engineering',
          'userEmail': 'student@example.com',
        },
        {
          'id': 2,
          'title': 'Finance',
          'field': 'Finance',
          'userEmail': 'student@example.com',
        },
        {
          'id': 3,
          'title': 'Hidden',
          'field': 'Computer Engineering',
          'userEmail': 'other@example.com',
        },
      ],
      'notes': [
        {
          'id': 1,
          'subject': 'Algorithms',
          'field': 'Computer Engineering',
          'content': 'Big O notes',
          'userEmail': 'student@example.com',
        },
      ],
      'tasks': [
        {
          'id': 1,
          'title': 'Revise sorting',
          'field': 'Computer Engineering',
          'userEmail': 'student@example.com',
        },
      ],
      'reminders': [
        {
          'id': 1,
          'title': 'Project demo',
          'field': 'Computer Engineering',
          'userEmail': 'student@example.com',
        },
      ],
    });
    final repository = BackupRepository(
      database: database,
      userScope: _FakeUserScope('student@example.com'),
      now: () => DateTime.utc(2026, 6, 9, 12),
    );

    final backup = await repository.exportField('Computer Engineering');
    final payload = jsonDecode(backup!.toPrettyJson()) as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>;

    expect(backup.subjectCount, 1);
    expect(backup.noteCount, 1);
    expect(backup.taskCount, 1);
    expect(backup.reminderCount, 1);
    expect(data.containsKey('users'), isFalse);
    expect(backup.toPrettyJson(), contains('Algorithms'));
    expect(backup.toPrettyJson(), isNot(contains('Hidden')));
    expect(backup.toPrettyJson(), isNot(contains('hashed-password')));
  });

  test('does not export without an active user', () async {
    final repository = BackupRepository(
      database: _FakeDatabase({}),
      userScope: _FakeUserScope(null),
    );

    expect(await repository.exportField('Basic'), isNull);
  });
}

class _FakeUserScope extends CurrentUserScope {
  final String? value;

  _FakeUserScope(this.value);

  @override
  Future<String?> email() async => value;
}

class _FakeDatabase implements AppDatabase {
  final Map<String, List<Map<String, dynamic>>> tables;

  _FakeDatabase(this.tables);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = tables[table] ?? [];
    final filtered = rows
        .where((row) {
          if (where == null) return true;

          if (where == 'field = ? AND userEmail = ?') {
            return row['field'] == whereArgs?[0] &&
                row['userEmail'] == whereArgs?[1];
          }

          return false;
        })
        .map((row) => Map<String, dynamic>.from(row));

    if (limit == null) return filtered.toList();

    return filtered.take(limit).toList();
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async => 0;

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async => 0;

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async => 0;
}

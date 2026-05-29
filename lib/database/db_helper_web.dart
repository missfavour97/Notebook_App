import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';

class DBHelper {
  static const List<String> _userScopedTables = [
    'subjects',
    'notes',
    'tasks',
    'reminders',
  ];

  static Future<AppDatabase> initDb() async {
    return WebAppDatabase(await SharedPreferences.getInstance());
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
}

class WebAppDatabase implements AppDatabase {
  final SharedPreferences _prefs;

  WebAppDatabase(this._prefs);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = _readTable(table)
        .where((row) => _matchesWhere(row, where, whereArgs))
        .map((row) => Map<String, dynamic>.from(row))
        .toList();

    _sortRows(rows, orderBy);

    if (limit != null && rows.length > limit) {
      return rows.take(limit).toList();
    }

    return rows;
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    final rows = _readTable(table);
    final row = Map<String, dynamic>.from(values);

    row['id'] ??= _nextId(table);
    rows.add(row);

    await _writeTable(table, rows);

    return row['id'] as int;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = _readTable(table);
    var count = 0;

    for (var index = 0; index < rows.length; index++) {
      if (_matchesWhere(rows[index], where, whereArgs)) {
        rows[index] = {...rows[index], ...values};
        count++;
      }
    }

    if (count > 0) {
      await _writeTable(table, rows);
    }

    return count;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = _readTable(table);
    final keptRows = rows
        .where((row) => !_matchesWhere(row, where, whereArgs))
        .toList();
    final count = rows.length - keptRows.length;

    if (count > 0) {
      await _writeTable(table, keptRows);
    }

    return count;
  }

  List<Map<String, dynamic>> _readTable(String table) {
    final encodedRows = _prefs.getString(_tableKey(table));

    if (encodedRows == null || encodedRows.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(encodedRows);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map((row) => row.map((key, value) => MapEntry(key.toString(), value)))
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<void> _writeTable(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    await _prefs.setString(_tableKey(table), jsonEncode(rows));
  }

  int _nextId(String table) {
    final key = _nextIdKey(table);
    final id = _prefs.getInt(key) ?? 1;

    _prefs.setInt(key, id + 1);

    return id;
  }

  bool _matchesWhere(
    Map<String, dynamic> row,
    String? where,
    List<Object?>? whereArgs,
  ) {
    if (where == null || where.trim().isEmpty) return true;

    final args = whereArgs ?? const [];
    final normalized = where.trim();

    if (normalized == 'userEmail IS NULL OR userEmail = ?') {
      final value = row['userEmail'];
      return value == null || value == '' || _valuesEqual(value, args.first);
    }

    final clauses = normalized.split(RegExp(r'\s+AND\s+'));
    var argIndex = 0;

    for (final clause in clauses) {
      final likeMatch = RegExp(
        r'^(\w+)\s+LIKE\s+\?$',
        caseSensitive: false,
      ).firstMatch(clause.trim());

      if (likeMatch != null) {
        final field = likeMatch.group(1)!;
        final pattern = args[argIndex++].toString();

        if (!_matchesLike(row[field], pattern)) {
          return false;
        }

        continue;
      }

      final equalsMatch = RegExp(r'^(\w+)\s*=\s*\?$').firstMatch(clause.trim());

      if (equalsMatch != null) {
        final field = equalsMatch.group(1)!;
        final expected = args[argIndex++];

        if (!_valuesEqual(row[field], expected)) {
          return false;
        }

        continue;
      }

      return false;
    }

    return true;
  }

  bool _matchesLike(Object? value, String pattern) {
    final text = value?.toString().toLowerCase() ?? '';
    final normalizedPattern = pattern.toLowerCase();

    if (normalizedPattern.startsWith('%') &&
        normalizedPattern.endsWith('%') &&
        normalizedPattern.length >= 2) {
      return text.contains(
        normalizedPattern.substring(1, normalizedPattern.length - 1),
      );
    }

    if (normalizedPattern.startsWith('%')) {
      return text.endsWith(normalizedPattern.substring(1));
    }

    if (normalizedPattern.endsWith('%')) {
      return text.startsWith(
        normalizedPattern.substring(0, normalizedPattern.length - 1),
      );
    }

    return text == normalizedPattern;
  }

  bool _valuesEqual(Object? actual, Object? expected) {
    if (actual is num && expected is num) {
      return actual == expected;
    }

    return actual?.toString() == expected?.toString();
  }

  void _sortRows(List<Map<String, dynamic>> rows, String? orderBy) {
    if (orderBy == null || orderBy.trim().isEmpty) return;

    final parts = orderBy.trim().split(RegExp(r'\s+'));
    final field = parts.first;
    final descending = parts.length > 1 && parts[1].toUpperCase() == 'DESC';

    rows.sort((left, right) {
      final comparison = _compareValues(left[field], right[field]);
      return descending ? -comparison : comparison;
    });
  }

  int _compareValues(Object? left, Object? right) {
    if (left is num && right is num) {
      return left.compareTo(right);
    }

    return (left?.toString() ?? '').compareTo(right?.toString() ?? '');
  }

  String _tableKey(String table) => 'webDb_$table';

  String _nextIdKey(String table) => 'webDb_${table}_nextId';
}

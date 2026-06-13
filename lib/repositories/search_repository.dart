import '../dao/note_dao.dart';
import '../dao/reminder_dao.dart';
import '../dao/subject_dao.dart';
import '../dao/task_dao.dart';
import 'current_user_scope.dart';

class SearchRepository {
  final SubjectDao subjectDao;
  final NoteDao noteDao;
  final TaskDao taskDao;
  final ReminderDao reminderDao;
  final CurrentUserScope userScope;

  SearchRepository({
    SubjectDao? subjectDao,
    NoteDao? noteDao,
    TaskDao? taskDao,
    ReminderDao? reminderDao,
    CurrentUserScope? userScope,
  }) : subjectDao = subjectDao ?? SubjectDao(),
       noteDao = noteDao ?? NoteDao(),
       taskDao = taskDao ?? TaskDao(),
       reminderDao = reminderDao ?? ReminderDao(),
       userScope = userScope ?? CurrentUserScope();

  Future<List<Map<String, dynamic>>> searchAll(
    String query,
    String field,
  ) async {
    final userEmail = await userScope.email();
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty || userEmail == null) {
      return [];
    }

    final results = await Future.wait<List<Map<String, dynamic>>>([
      subjectDao.searchByTitle(
        field: field,
        userEmail: userEmail,
        query: normalizedQuery,
      ),
      noteDao.searchByContent(
        field: field,
        userEmail: userEmail,
        query: normalizedQuery,
      ),
      taskDao.searchByTitle(
        field: field,
        userEmail: userEmail,
        query: normalizedQuery,
      ),
      reminderDao.searchByTitle(
        field: field,
        userEmail: userEmail,
        query: normalizedQuery,
      ),
    ]);

    final subjects = results[0];
    final notes = results[1];
    final tasks = results[2];
    final reminders = results[3];

    return [
      ...subjects.map(
        (item) => {
          'type': 'Subject',
          'title': item['title'],
          'subtitle': field,
        },
      ),
      ...notes.map(
        (item) => {
          'type': 'Note',
          'title': item['subject'],
          'subtitle': item['content'],
        },
      ),
      ...tasks.map(
        (item) => {
          'type': 'Task',
          'title': item['title'],
          'subtitle': item['isCompleted'] == 1 ? 'Completed' : 'Pending',
        },
      ),
      ...reminders.map(
        (item) => {
          'type': 'Reminder',
          'title': item['title'],
          'subtitle': item['reminderDate'],
        },
      ),
    ];
  }
}

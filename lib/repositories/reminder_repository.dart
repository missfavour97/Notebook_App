import '../dao/reminder_dao.dart';
import 'current_user_scope.dart';

class ReminderRepository {
  final ReminderDao reminderDao;
  final CurrentUserScope userScope;

  ReminderRepository({ReminderDao? reminderDao, CurrentUserScope? userScope})
    : reminderDao = reminderDao ?? ReminderDao(),
      userScope = userScope ?? CurrentUserScope();

  Future<List<Map<String, dynamic>>> loadReminders(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return [];

    return await reminderDao.findByField(field: field, userEmail: userEmail);
  }

  Future<int> countReminders(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return 0;

    return await reminderDao.countByField(field: field, userEmail: userEmail);
  }

  Future<void> addReminder(
    String title,
    String reminderDate,
    String field,
  ) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await reminderDao.insertReminder(
      title: title,
      reminderDate: reminderDate,
      field: field,
      userEmail: userEmail,
    );
  }

  Future<void> deleteReminder(int id) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await reminderDao.deleteReminder(id: id, userEmail: userEmail);
  }
}

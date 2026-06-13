import '../repositories/reminder_repository.dart';

class ReminderController {
  final ReminderRepository reminderRepository;

  ReminderController({ReminderRepository? reminderRepository})
    : reminderRepository = reminderRepository ?? ReminderRepository();

  Future<List<Map<String, dynamic>>> loadReminders(String field) async {
    return await reminderRepository.loadReminders(field);
  }

  Future<void> addReminder(
    String title,
    String reminderDate,
    String field,
  ) async {
    await reminderRepository.addReminder(title, reminderDate, field);
  }

  Future<void> deleteReminder(int id) async {
    await reminderRepository.deleteReminder(id);
  }
}

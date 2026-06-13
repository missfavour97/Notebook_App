import 'note_repository.dart';
import 'reminder_repository.dart';
import 'subject_repository.dart';
import 'task_repository.dart';

class DashboardCounts {
  final int subjects;
  final int notes;
  final int tasks;
  final int reminders;

  const DashboardCounts({
    required this.subjects,
    required this.notes,
    required this.tasks,
    required this.reminders,
  });
}

class DashboardRepository {
  final SubjectRepository subjectRepository;
  final NoteRepository noteRepository;
  final TaskRepository taskRepository;
  final ReminderRepository reminderRepository;

  DashboardRepository({
    SubjectRepository? subjectRepository,
    NoteRepository? noteRepository,
    TaskRepository? taskRepository,
    ReminderRepository? reminderRepository,
  }) : subjectRepository = subjectRepository ?? SubjectRepository(),
       noteRepository = noteRepository ?? NoteRepository(),
       taskRepository = taskRepository ?? TaskRepository(),
       reminderRepository = reminderRepository ?? ReminderRepository();

  Future<DashboardCounts> loadCounts(String field) async {
    final results = await Future.wait<int>([
      subjectRepository.countSubjects(field),
      noteRepository.countNotes(field),
      taskRepository.countTasks(field),
      reminderRepository.countReminders(field),
    ]);

    return DashboardCounts(
      subjects: results[0],
      notes: results[1],
      tasks: results[2],
      reminders: results[3],
    );
  }

  Future<List<Map<String, dynamic>>> loadRecentSubjects(String field) async {
    final subjects = await subjectRepository.getSubjects(field);

    return subjects.take(4).toList();
  }
}

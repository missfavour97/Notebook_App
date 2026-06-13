import '../repositories/task_repository.dart';

class TaskController {
  final TaskRepository taskRepository;

  TaskController({TaskRepository? taskRepository})
    : taskRepository = taskRepository ?? TaskRepository();

  Future<List<Map<String, dynamic>>> loadTasks(String field) async {
    return await taskRepository.loadTasks(field);
  }

  Future<void> addTask(String title, String field) async {
    await taskRepository.addTask(title, field);
  }

  Future<void> toggleTask(int id, bool isCompleted) async {
    await taskRepository.toggleTask(id, isCompleted);
  }

  Future<void> deleteTask(int id) async {
    await taskRepository.deleteTask(id);
  }
}

import '../dao/task_dao.dart';
import 'current_user_scope.dart';

class TaskRepository {
  final TaskDao taskDao;
  final CurrentUserScope userScope;

  TaskRepository({TaskDao? taskDao, CurrentUserScope? userScope})
    : taskDao = taskDao ?? TaskDao(),
      userScope = userScope ?? CurrentUserScope();

  Future<List<Map<String, dynamic>>> loadTasks(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return [];

    return await taskDao.findByField(field: field, userEmail: userEmail);
  }

  Future<int> countTasks(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return 0;

    return await taskDao.countByField(field: field, userEmail: userEmail);
  }

  Future<void> addTask(String title, String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await taskDao.insertTask(title: title, field: field, userEmail: userEmail);
  }

  Future<void> toggleTask(int id, bool isCompleted) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await taskDao.updateCompletion(
      id: id,
      isCompleted: isCompleted,
      userEmail: userEmail,
    );
  }

  Future<void> deleteTask(int id) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await taskDao.deleteTask(id: id, userEmail: userEmail);
  }
}

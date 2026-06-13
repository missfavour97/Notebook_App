import '../dao/subject_dao.dart';
import 'current_user_scope.dart';

class SubjectRepository {
  final SubjectDao subjectDao;
  final CurrentUserScope userScope;

  SubjectRepository({SubjectDao? subjectDao, CurrentUserScope? userScope})
    : subjectDao = subjectDao ?? SubjectDao(),
      userScope = userScope ?? CurrentUserScope();

  Future<List<Map<String, dynamic>>> getSubjects(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return [];

    return await subjectDao.findByField(field: field, userEmail: userEmail);
  }

  Future<int> countSubjects(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return 0;

    return await subjectDao.countByField(field: field, userEmail: userEmail);
  }

  Future<void> addSubject(
    String title,
    String field, {
    int? coverColor,
    String? coverPattern,
  }) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await subjectDao.insertSubject(
      title: title,
      field: field,
      userEmail: userEmail,
      coverColor: coverColor,
      coverPattern: coverPattern,
    );
  }

  Future<void> updateSubject(
    int id,
    String newTitle, {
    int? coverColor,
    String? coverPattern,
  }) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await subjectDao.updateSubject(
      id: id,
      userEmail: userEmail,
      values: {
        'title': newTitle,
        'coverColor': coverColor,
        'coverPattern': coverPattern,
      },
    );
  }

  Future<void> deleteSubject(int id) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await subjectDao.deleteSubject(id: id, userEmail: userEmail);
  }
}

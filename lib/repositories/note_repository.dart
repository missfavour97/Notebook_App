import '../dao/note_dao.dart';
import 'current_user_scope.dart';

class NoteRepository {
  final NoteDao noteDao;
  final CurrentUserScope userScope;

  NoteRepository({NoteDao? noteDao, CurrentUserScope? userScope})
    : noteDao = noteDao ?? NoteDao(),
      userScope = userScope ?? CurrentUserScope();

  Future<Map<String, dynamic>?> loadNote(String subject, String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return null;

    return await noteDao.findBySubjectAndField(
      subject: subject,
      field: field,
      userEmail: userEmail,
    );
  }

  Future<List<Map<String, dynamic>>> loadNotes(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return [];

    return await noteDao.findByField(field: field, userEmail: userEmail);
  }

  Future<int> countNotes(String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return 0;

    return await noteDao.countByField(field: field, userEmail: userEmail);
  }

  Future<void> saveNote(
    String subject,
    String field,
    String content,
    String noteType,
    String drawing,
  ) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await noteDao.upsertNote(
      subject: subject,
      field: field,
      content: content,
      noteType: noteType,
      drawing: drawing,
      userEmail: userEmail,
    );
  }

  Future<void> deleteNote(String subject, String field) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await noteDao.deleteNote(
      subject: subject,
      field: field,
      userEmail: userEmail,
    );
  }
}

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

  Future<Map<String, dynamic>?> loadNoteById(int id) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return null;

    return await noteDao.findById(id: id, userEmail: userEmail);
  }

  Future<List<Map<String, dynamic>>> loadSubjectNotes(
    String subject,
    String field,
  ) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return [];

    return await noteDao.findBySubject(
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

  Future<int?> createNote({
    required String subject,
    required String field,
    required String noteType,
    String? title,
  }) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return null;

    return await noteDao.insertNote(
      title: title ?? noteDao.defaultTitle(noteType),
      subject: subject,
      field: field,
      content: '',
      noteType: noteType,
      drawing: '',
      userEmail: userEmail,
    );
  }

  Future<int?> saveNote(
    String subject,
    String field,
    String content,
    String noteType,
    String drawing, {
    int? id,
    String? title,
  }) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return null;

    return await noteDao.upsertNote(
      id: id,
      title: title,
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

  Future<void> deleteNoteById(int id) async {
    final userEmail = await userScope.email();

    if (userEmail == null) return;

    await noteDao.deleteNoteById(id: id, userEmail: userEmail);
  }
}

import '../repositories/note_repository.dart';

class NoteController {
  final NoteRepository noteRepository;

  NoteController({NoteRepository? noteRepository})
    : noteRepository = noteRepository ?? NoteRepository();

  Future<Map<String, dynamic>?> loadNote(String subject, String field) async {
    return await noteRepository.loadNote(subject, field);
  }

  Future<Map<String, dynamic>?> loadNoteById(int id) async {
    return await noteRepository.loadNoteById(id);
  }

  Future<List<Map<String, dynamic>>> loadSubjectNotes(
    String subject,
    String field,
  ) async {
    return await noteRepository.loadSubjectNotes(subject, field);
  }

  Future<List<Map<String, dynamic>>> loadNotes(String field) async {
    return await noteRepository.loadNotes(field);
  }

  Future<int?> createNote({
    required String subject,
    required String field,
    required String noteType,
    String? title,
  }) async {
    return await noteRepository.createNote(
      subject: subject,
      field: field,
      noteType: noteType,
      title: title,
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
    return await noteRepository.saveNote(
      subject,
      field,
      content,
      noteType,
      drawing,
      id: id,
      title: title,
    );
  }

  Future<void> deleteNote(String subject, String field) async {
    await noteRepository.deleteNote(subject, field);
  }

  Future<void> deleteNoteById(int id) async {
    await noteRepository.deleteNoteById(id);
  }
}

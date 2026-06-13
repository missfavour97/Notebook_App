import '../repositories/note_repository.dart';

class NoteController {
  final NoteRepository noteRepository;

  NoteController({NoteRepository? noteRepository})
    : noteRepository = noteRepository ?? NoteRepository();

  Future<Map<String, dynamic>?> loadNote(String subject, String field) async {
    return await noteRepository.loadNote(subject, field);
  }

  Future<List<Map<String, dynamic>>> loadNotes(String field) async {
    return await noteRepository.loadNotes(field);
  }

  Future<void> saveNote(
    String subject,
    String field,
    String content,
    String noteType,
    String drawing,
  ) async {
    await noteRepository.saveNote(subject, field, content, noteType, drawing);
  }

  Future<void> deleteNote(String subject, String field) async {
    await noteRepository.deleteNote(subject, field);
  }
}

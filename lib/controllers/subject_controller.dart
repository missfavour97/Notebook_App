import '../repositories/subject_repository.dart';

class SubjectController {
  final SubjectRepository _subjectRepository = SubjectRepository();

  Future<List<Map<String, dynamic>>> loadSubjects(String field) async {
    return await _subjectRepository.getSubjects(field);
  }

  Future<void> addSubject(
    String title,
    String field, {
    int? coverColor,
    String? coverPattern,
  }) async {
    if (title.trim().isEmpty) return;

    await _subjectRepository.addSubject(
      title,
      field,
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
    if (newTitle.trim().isEmpty) return;

    await _subjectRepository.updateSubject(
      id,
      newTitle,
      coverColor: coverColor,
      coverPattern: coverPattern,
    );
  }

  Future<void> renameSubject(int id, String newTitle) async {
    await updateSubject(id, newTitle);
  }

  Future<void> deleteSubject(int id) async {
    await _subjectRepository.deleteSubject(id);
  }
}

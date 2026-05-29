class SubjectModule {
  final int? id;
  final String title;
  final String field;

  SubjectModule({
    this.id,
    required this.title,
    required this.field,
  });

  Map<String, dynamic> toMap () {
    return {
      'id': id,
      'title': title,
      'field': field,
    };
  }
}
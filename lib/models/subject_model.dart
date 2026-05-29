class SubjectModule {
  final int? id;
  final String title;
  final String field;
  final String userEmail;

  SubjectModule({
    this.id,
    required this.title,
    required this.field,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'field': field, 'userEmail': userEmail};
  }
}

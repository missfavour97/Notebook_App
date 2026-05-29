class SubjectModule {
  final int? id;
  final String title;
  final String field;
  final String userEmail;
  final int? coverColor;
  final String? coverPattern;

  SubjectModule({
    this.id,
    required this.title,
    required this.field,
    required this.userEmail,
    this.coverColor,
    this.coverPattern,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'field': field,
      'userEmail': userEmail,
      'coverColor': coverColor,
      'coverPattern': coverPattern,
    };
  }
}

import '../repositories/search_repository.dart';

class AppSearchController {
  final SearchRepository searchRepository;

  AppSearchController({SearchRepository? searchRepository})
    : searchRepository = searchRepository ?? SearchRepository();

  Future<List<Map<String, dynamic>>> searchAll(
    String query,
    String field,
  ) async {
    return await searchRepository.searchAll(query, field);
  }
}

import '../database/db_helper.dart';

class CurrentUserScope {
  Future<String?> email() async {
    return await DBHelper.currentUserEmail();
  }
}

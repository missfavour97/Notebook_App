import 'package:shared_preferences/shared_preferences.dart';

class SessionController {
  Future<void> saveLoginSession(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
  }

  Future<void> saveSelectedField(String email, String field) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedField_$email', field);
  }

  Future<String?> getSavedField(String email) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('selectedField_$email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('userEmail');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
  }
}

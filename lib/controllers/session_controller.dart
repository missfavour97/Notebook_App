import 'package:shared_preferences/shared_preferences.dart';

class SessionController {
  Future<void> saveLoginSession(String email, {bool rememberMe = true}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', rememberMe);
    await prefs.setBool('rememberMe', rememberMe);
    await prefs.setString('userEmail', email);

    if (rememberMe) {
      await prefs.setString('rememberedEmail', email);
    }
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

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    return isLoggedIn && rememberMe;
  }

  Future<bool> shouldRememberUser() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('rememberMe') ?? false;
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('rememberedEmail');
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

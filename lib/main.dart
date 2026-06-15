import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'controllers/theme_controller.dart';
import 'screens/field_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await AppThemeController.init();
  runApp(const StudentNotebookApp());
}

class StudentNotebookApp extends StatelessWidget {
  const StudentNotebookApp({super.key});

  Future<Widget> getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    final email = prefs.getString('userEmail');

    if (isLoggedIn && rememberMe && email != null && email.isNotEmpty) {
      await DBHelper.claimLegacyData(email);

      final savedField = prefs.getString('selectedField_$email');

      if (savedField != null && savedField.isNotEmpty) {
        return HomeScreen(selectedField: savedField);
      }

      return const FieldSelectionScreen();
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: AppThemeController.seedColor,
      builder: (context, seedColor, _) {
        final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Notebook',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: colorScheme.surface,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: colorScheme.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
          home: FutureBuilder(
            future: getStartScreen(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return snapshot.data!;
            },
          ),
        );
      },
    );
  }
}

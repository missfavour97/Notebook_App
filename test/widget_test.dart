import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_notebook/main.dart';

void main() {
  testWidgets('shows login screen when there is no active session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});

    await tester.pumpWidget(const StudentNotebookApp());
    await tester.pumpAndSettle();

    expect(find.text('My Notebook'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'subjects_screen.dart';
import 'notes_screen.dart';
import 'tasks_screen.dart';
import 'reminders_screens.dart';
import '../controllers/session_controller.dart';
import 'search_screen.dart';
import 'resources_screen.dart';
import 'theme_screen.dart';
import '../database/db_helper.dart';

class HomeScreen extends StatefulWidget {
  final String selectedField;

  const HomeScreen({super.key, required this.selectedField});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionController sessionController = SessionController();

  int subjectCount = 0;
  int noteCount = 0;
  int taskCount = 0;
  int reminderCount = 0;

  @override
  void initState() {
    super.initState();
    rememberSelectedField();
    loadDashboardCounts();
  }

  Future<void> rememberSelectedField() async {
    final email = await sessionController.getUserEmail();

    if (email != null && email.isNotEmpty) {
      await sessionController.saveSelectedField(email, widget.selectedField);
    }
  }

  Future<void> loadDashboardCounts() async {
    final db = await DBHelper.initDb();
    final userEmail = await sessionController.getUserEmail();

    if (userEmail == null) return;

    final subjects = await db.query(
      'subjects',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [widget.selectedField, userEmail],
    );

    final notes = await db.query(
      'notes',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [widget.selectedField, userEmail],
    );

    final tasks = await db.query(
      'tasks',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [widget.selectedField, userEmail],
    );

    final reminders = await db.query(
      'reminders',
      where: 'field = ? AND userEmail = ?',
      whereArgs: [widget.selectedField, userEmail],
    );

    if (!mounted) return;

    setState(() {
      subjectCount = subjects.length;
      noteCount = notes.length;
      taskCount = tasks.length;
      reminderCount = reminders.length;
    });
  }

  Future<void> logout(BuildContext context) async {
    await sessionController.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'My Notebook',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.selectedField,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                _buildSidebarItem(context, Icons.home, 'Home'),
                _buildSidebarItem(context, Icons.menu_book, 'Subjects'),
                _buildSidebarItem(context, Icons.note, 'Notes'),
                _buildSidebarItem(context, Icons.check_circle, 'Tasks'),
                _buildSidebarItem(context, Icons.alarm, 'Reminders'),
                _buildSidebarItem(context, Icons.search, 'Search'),
                _buildSidebarItem(context, Icons.library_books, 'Resources'),
                _buildSidebarItem(context, Icons.palette, 'Theme'),
                const Spacer(),
                _buildSidebarItem(context, Icons.logout, 'Logout'),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to My Notebook',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mode: ${widget.selectedField}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Subjects',
                        subjectCount.toString(),
                        Icons.menu_book,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryCard(
                        'Notes',
                        noteCount.toString(),
                        Icons.note,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryCard(
                        'Tasks',
                        taskCount.toString(),
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 20),
                      _buildSummaryCard(
                        'Reminders',
                        reminderCount.toString(),
                        Icons.alarm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildDashboardContent(widget.selectedField),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(String field) {
    if (field == 'Basic') {
      return _buildContentBlock(
        title: 'General Notebook Dashboard',
        description:
            'A simple productivity space for your everyday notes and study planning.',
        items: const [
          'Quick notes',
          'Personal tasks',
          'Study reminders',
          'General subjects',
        ],
      );
    } else if (field == 'Accounting') {
      return _buildContentBlock(
        title: 'Accounting Dashboard',
        description:
            'Organize accounting records, study notes, and report-based tasks.',
        items: const [
          'Financial notes',
          'Balance sheet practice',
          'Assignment tracker',
          'Exam reminders',
        ],
      );
    } else if (field == 'Finance') {
      return _buildContentBlock(
        title: 'Finance Dashboard',
        description:
            'Manage finance notes, deadlines, and calculation-focused study work.',
        items: const [
          'Investment notes',
          'Budget planning',
          'Case study tasks',
          'Deadline tracking',
        ],
      );
    } else if (field == 'Marketing') {
      return _buildContentBlock(
        title: 'Marketing Dashboard',
        description:
            'Keep campaign ideas, branding notes, and presentation tasks in one place.',
        items: const [
          'Campaign notes',
          'Brand strategy ideas',
          'Presentation tasks',
          'Research reminders',
        ],
      );
    } else if (field == 'Management') {
      return _buildContentBlock(
        title: 'Management Dashboard',
        description:
            'Plan meetings, leadership notes, and project organization tasks.',
        items: const [
          'Meeting notes',
          'Project tasks',
          'Leadership summaries',
          'Schedule reminders',
        ],
      );
    } else if (field == 'Computer Engineering') {
      return _buildContentBlock(
        title: 'Computer Engineering Dashboard',
        description:
            'Track technical notes, coding tasks, and system-based coursework.',
        items: const [
          'Programming notes',
          'Lab tasks',
          'Project tracker',
          'Exam reminders',
        ],
      );
    } else if (field == 'Mechanical Engineering') {
      return _buildContentBlock(
        title: 'Mechanical Engineering Dashboard',
        description:
            'Manage mechanics notes, lab work, and engineering project tasks.',
        items: const [
          'Mechanics notes',
          'Lab records',
          'Design tasks',
          'Assignment reminders',
        ],
      );
    } else if (field == 'Electrical Engineering') {
      return _buildContentBlock(
        title: 'Electrical Engineering Dashboard',
        description:
            'Store circuit notes, electrical concepts, and practical task planning.',
        items: const [
          'Circuit notes',
          'Electronics tasks',
          'Lab reminders',
          'Project planning',
        ],
      );
    } else if (field == 'Medicine') {
      return _buildContentBlock(
        title: 'Medicine Dashboard',
        description: 'Organize medical notes, cases, and academic reminders.',
        items: const [
          'Clinical notes',
          'Case reviews',
          'Exam preparation',
          'Medical reminders',
        ],
      );
    } else if (field == 'Pharmacy') {
      return _buildContentBlock(
        title: 'Pharmacy Dashboard',
        description:
            'Track medication notes, pharmacology study materials, and tasks.',
        items: const [
          'Drug notes',
          'Pharmacology tasks',
          'Study summaries',
          'Exam reminders',
        ],
      );
    } else if (field == 'Nursing') {
      return _buildContentBlock(
        title: 'Nursing Dashboard',
        description:
            'Manage nursing notes, shift-related tasks, and practical study reminders.',
        items: const [
          'Clinical notes',
          'Shift tasks',
          'Patient care reminders',
          'Practical exam prep',
        ],
      );
    }

    return _buildContentBlock(
      title: '$field Dashboard',
      description: 'Your personalized notebook dashboard.',
      items: const ['Notes', 'Tasks', 'Reminders', 'Resources'],
    );
  }

  Widget _buildContentBlock({
    required String title,
    required String description,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quick Focus',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 10),
                Text(item, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        if (title == 'Subjects') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SubjectsScreen(selectedField: widget.selectedField),
            ),
          );
          loadDashboardCounts();
        } else if (title == 'Notes') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotesScreen(selectedField: widget.selectedField),
            ),
          );
          loadDashboardCounts();
        } else if (title == 'Tasks') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TasksScreen(selectedField: widget.selectedField),
            ),
          );
          loadDashboardCounts();
        } else if (title == 'Reminders') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RemindersScreen(selectedField: widget.selectedField),
            ),
          );
          loadDashboardCounts();
        } else if (title == 'Search') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchScreen(selectedField: widget.selectedField),
            ),
          );
        } else if (title == 'Resources') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResourcesScreen(selectedField: widget.selectedField),
            ),
          );
        } else if (title == 'Theme') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ThemeScreen()),
          );
        } else if (title == 'Logout') {
          logout(context);
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}

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
import 'backup_screen.dart';
import '../repositories/dashboard_repository.dart';
import '../widgets/notebook_cover.dart';

class HomeScreen extends StatefulWidget {
  final String selectedField;

  const HomeScreen({super.key, required this.selectedField});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionController sessionController = SessionController();
  final DashboardRepository dashboardRepository = DashboardRepository();

  int subjectCount = 0;
  int noteCount = 0;
  int taskCount = 0;
  int reminderCount = 0;
  List<Map<String, dynamic>> recentSubjects = [];

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
    final results = await Future.wait<dynamic>([
      dashboardRepository.loadCounts(widget.selectedField),
      dashboardRepository.loadRecentSubjects(widget.selectedField),
    ]);
    final counts = results[0] as DashboardCounts;
    final subjects = results[1] as List<Map<String, dynamic>>;

    if (!mounted) return;

    setState(() {
      subjectCount = counts.subjects;
      noteCount = counts.notes;
      taskCount = counts.tasks;
      reminderCount = counts.reminders;
      recentSubjects = subjects;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return Scaffold(
          appBar: isCompact
              ? AppBar(
                  title: const Text('My Notebook'),
                  actions: [
                    IconButton(
                      tooltip: 'Refresh dashboard',
                      onPressed: loadDashboardCounts,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              : null,
          drawer: isCompact
              ? Drawer(
                  child: Builder(
                    builder: (drawerContext) => _buildSidebar(drawerContext),
                  ),
                )
              : null,
          body: isCompact
              ? _buildMainContent(isCompact: true)
              : Row(
                  children: [
                    SizedBox(width: 220, child: _buildSidebar(context)),
                    Expanded(child: _buildMainContent(isCompact: false)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
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
            _buildSidebarItem(context, Icons.inventory_2_outlined, 'Backup'),
            _buildSidebarItem(context, Icons.palette, 'Theme'),
            const Spacer(),
            _buildSidebarItem(context, Icons.logout, 'Logout'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({required bool isCompact}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to My Notebook',
            style: TextStyle(
              fontSize: isCompact ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Mode: ${widget.selectedField}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: isCompact ? 18 : 30),
          _buildSummaryCards(isCompact: isCompact),
          SizedBox(height: isCompact ? 18 : 30),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompact ? 18 : 24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDashboardContent(widget.selectedField),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentShelf(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards({required bool isCompact}) {
    final cards = [
      _buildSummaryCard(
        'Subjects',
        subjectCount.toString(),
        Icons.menu_book,
        expanded: !isCompact,
      ),
      _buildSummaryCard(
        'Notes',
        noteCount.toString(),
        Icons.note,
        expanded: !isCompact,
      ),
      _buildSummaryCard(
        'Tasks',
        taskCount.toString(),
        Icons.check_circle,
        expanded: !isCompact,
      ),
      _buildSummaryCard(
        'Reminders',
        reminderCount.toString(),
        Icons.alarm,
        expanded: !isCompact,
      ),
    ];

    if (isCompact) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cards,
      );
    }

    return Row(
      children: [
        cards[0],
        const SizedBox(width: 20),
        cards[1],
        const SizedBox(width: 20),
        cards[2],
        const SizedBox(width: 20),
        cards[3],
      ],
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

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionChip(Icons.menu_book, 'Subjects', () {
          _openSubjects();
        }),
        _buildActionChip(Icons.note_add, 'Notes', () {
          _openNotes();
        }),
        _buildActionChip(Icons.library_books, 'Resources', () {
          _openResources();
        }),
        _buildActionChip(Icons.inventory_2_outlined, 'Backup', () {
          _openBackup();
        }),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.surface,
      shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
    );
  }

  Widget _buildRecentShelf() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Notebook Shelf',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openSubjects,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Open'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentSubjects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Create your first subject to start building the shelf.',
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 166,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentSubjects.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final subject = recentSubjects[index];
                final title = subject['title']?.toString() ?? '';

                return SizedBox(
                  width: 118,
                  child: NotebookCover(
                    title: title,
                    subtitle: widget.selectedField,
                    cover: NotebookCoverStyles.fromSubject(subject),
                    height: 158,
                    compact: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _openSubjects() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubjectsScreen(selectedField: widget.selectedField),
      ),
    );
    loadDashboardCounts();
  }

  Future<void> _openNotes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesScreen(selectedField: widget.selectedField),
      ),
    );
    loadDashboardCounts();
  }

  Future<void> _openTasks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasksScreen(selectedField: widget.selectedField),
      ),
    );
    loadDashboardCounts();
  }

  Future<void> _openReminders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RemindersScreen(selectedField: widget.selectedField),
      ),
    );
    loadDashboardCounts();
  }

  Future<void> _openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(selectedField: widget.selectedField),
      ),
    );
  }

  Future<void> _openResources() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResourcesScreen(selectedField: widget.selectedField),
      ),
    );
  }

  Future<void> _openBackup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupScreen(selectedField: widget.selectedField),
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        final navigationContext = this.context;
        final scaffold = Scaffold.maybeOf(context);
        final shouldCloseDrawer = scaffold?.isDrawerOpen ?? false;

        if (shouldCloseDrawer) {
          Navigator.pop(context);
        }

        if (title == 'Home') {
          loadDashboardCounts();
        } else if (title == 'Subjects') {
          await _openSubjects();
        } else if (title == 'Notes') {
          await _openNotes();
        } else if (title == 'Tasks') {
          await _openTasks();
        } else if (title == 'Reminders') {
          await _openReminders();
        } else if (title == 'Search') {
          await _openSearch();
        } else if (title == 'Resources') {
          await _openResources();
        } else if (title == 'Backup') {
          await _openBackup();
        } else if (title == 'Theme') {
          await Navigator.push(
            navigationContext,
            MaterialPageRoute(builder: (context) => const ThemeScreen()),
          );
        } else if (title == 'Logout') {
          logout(navigationContext);
        }
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon, {
    bool expanded = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );

    if (!expanded) return card;

    return Expanded(child: card);
  }
}

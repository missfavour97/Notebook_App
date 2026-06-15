import 'package:flutter/material.dart';
import 'subject_note_screen.dart';
import '../controllers/note_controller.dart';
import '../controllers/subject_controller.dart';
import '../widgets/notebook_cover.dart';

class SubjectsScreen extends StatefulWidget {
  final String selectedField;

  const SubjectsScreen({super.key, required this.selectedField});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Map<String, dynamic>> subjects = [];

  final SubjectController subjectController = SubjectController();
  final NoteController noteController = NoteController();

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final data = await subjectController.loadSubjects(widget.selectedField);

    if (!mounted) return;

    setState(() {
      subjects = data;
    });
  }

  Future<void> addSubjectDialog() async {
    final controller = TextEditingController();
    var selectedCover = NotebookCoverStyles
        .options[subjects.length % NotebookCoverStyles.options.length];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add Subject'),
              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter subject name',
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Choose cover',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      buildCoverPicker(
                        selectedCover: selectedCover,
                        onSelected: (cover) {
                          setDialogState(() {
                            selectedCover = cover;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    await subjectController.addSubject(
                      controller.text.trim(),
                      widget.selectedField,
                      coverColor: selectedCover.color.toARGB32(),
                      coverPattern: selectedCover.pattern,
                    );

                    if (!mounted || !dialogContext.mounted) return;

                    Navigator.pop(dialogContext);
                    loadSubjects();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> editSubjectDialog(Map<String, dynamic> subject) async {
    final controller = TextEditingController(text: subject['title']);
    var selectedCover = NotebookCoverStyles.fromSubject(subject);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Subject'),
              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter new subject name',
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Choose cover',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      buildCoverPicker(
                        selectedCover: selectedCover,
                        onSelected: (cover) {
                          setDialogState(() {
                            selectedCover = cover;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    await subjectController.updateSubject(
                      subject['id'],
                      controller.text.trim(),
                      coverColor: selectedCover.color.toARGB32(),
                      coverPattern: selectedCover.pattern,
                    );

                    if (!mounted || !dialogContext.mounted) return;

                    Navigator.pop(dialogContext);
                    loadSubjects();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteSubject(int id) async {
    await subjectController.deleteSubject(id);
    loadSubjects();
  }

  Future<void> openSubject(Map<String, dynamic> subject) async {
    final subjectTitle = subject['title']?.toString() ?? '';
    final notes = await noteController.loadSubjectNotes(
      subjectTitle,
      widget.selectedField,
    );

    if (!mounted) return;

    if (notes.isEmpty) {
      chooseNoteType(subject, existingNoteCount: 0);
      return;
    }

    showSubjectNotesDialog(subject, notes);
  }

  Future<void> showSubjectNotesDialog(
    Map<String, dynamic> subject,
    List<Map<String, dynamic>> notes,
  ) async {
    final subjectTitle = subject['title']?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjectTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Continue a note or create a new page.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      chooseNoteType(subject, existingNoteCount: notes.length);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add new note'),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final note = notes[index];

                        return Material(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.primary,
                              child: const Icon(Icons.note_alt_outlined),
                            ),
                            title: Text(
                              noteTitle(note),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${note['noteType'] ?? 'Blank Note'} • ${notePreview(note)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              openExistingNote(note);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> openExistingNote(Map<String, dynamic> note) async {
    final id = note['id'];

    if (id is! num) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectNoteScreen(
          noteId: id.toInt(),
          noteTitle: noteTitle(note),
          subjectTitle: note['subject']?.toString() ?? '',
          selectedField: widget.selectedField,
          noteType: note['noteType']?.toString() ?? 'Blank Note',
        ),
      ),
    );
  }

  void chooseNoteType(
    Map<String, dynamic> subject, {
    required int existingNoteCount,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Note Type',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subject['title'],
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    buildNoteTypeCard(
                      subject,
                      'Blank Note',
                      Icons.crop_square,
                      existingNoteCount,
                    ),
                    buildNoteTypeCard(
                      subject,
                      'Lined Note',
                      Icons.menu,
                      existingNoteCount,
                    ),
                    buildNoteTypeCard(
                      subject,
                      'Grid Note',
                      Icons.grid_on,
                      existingNoteCount,
                    ),
                    buildNoteTypeCard(
                      subject,
                      'Template Note',
                      Icons.description,
                      existingNoteCount,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildNoteTypeCard(
    Map<String, dynamic> subject,
    String noteType,
    IconData icon,
    int existingNoteCount,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final subjectTitle = subject['title']?.toString() ?? '';
        final title = existingNoteCount == 0
            ? noteType
            : '$noteType ${existingNoteCount + 1}';

        final noteId = await noteController.createNote(
          subject: subjectTitle,
          field: widget.selectedField,
          noteType: noteType,
          title: title,
        );

        if (!mounted || noteId == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectNoteScreen(
              noteId: noteId,
              noteTitle: title,
              subjectTitle: subjectTitle,
              selectedField: widget.selectedField,
              noteType: noteType,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(noteType, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String noteTitle(Map<String, dynamic> note) {
    final title = note['title']?.toString().trim() ?? '';

    if (title.isNotEmpty) return title;

    return note['noteType']?.toString() ?? 'Untitled Note';
  }

  String notePreview(Map<String, dynamic> note) {
    final content = note['content']?.toString().trim() ?? '';
    final drawing = note['drawing']?.toString() ?? '';

    if (content.isNotEmpty) {
      return content.length > 80 ? '${content.substring(0, 80)}...' : content;
    }

    if (drawing.isNotEmpty && drawing != '[]') {
      return 'Drawing and page elements';
    }

    return 'Empty note';
  }

  Widget buildCoverPicker({
    required NotebookCoverOption selectedCover,
    required ValueChanged<NotebookCoverOption> onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: NotebookCoverStyles.options.map((cover) {
        final isSelected =
            cover.color.toARGB32() == selectedCover.color.toARGB32() &&
            cover.pattern == selectedCover.pattern;

        return NotebookCoverSwatch(
          cover: cover,
          isSelected: isSelected,
          onTap: () => onSelected(cover),
        );
      }).toList(),
    );
  }

  Widget buildSubjectCard(Map<String, dynamic> subject) {
    final cover = NotebookCoverStyles.fromSubject(subject);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openSubject(subject),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NotebookCover(
              title: subject['title']?.toString() ?? '',
              subtitle: widget.selectedField,
              cover: cover,
              height: 190,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['title']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subject['field']?.toString() ?? widget.selectedField,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit subject',
                    icon: const Icon(Icons.edit),
                    onPressed: () => editSubjectDialog(subject),
                  ),
                  IconButton(
                    tooltip: 'Delete subject',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => deleteSubject(subject['id']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 118,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_stories,
                size: 44,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Start your shelf',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              widget.selectedField,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: addSubjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add subject'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedField} Subjects')),
      floatingActionButton: FloatingActionButton(
        onPressed: addSubjectDialog,
        child: const Icon(Icons.add),
      ),
      body: subjects.isEmpty
          ? buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth ~/ 230)
                    .clamp(1, 5)
                    .toInt();

                return GridView.builder(
                  padding: const EdgeInsets.all(18),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 276,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return buildSubjectCard(subjects[index]);
                  },
                );
              },
            ),
    );
  }
}

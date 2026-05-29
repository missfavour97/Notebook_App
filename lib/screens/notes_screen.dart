import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../controllers/subject_controller.dart';
import '../widgets/notebook_cover.dart';
import 'subject_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final String selectedField;

  const NotesScreen({super.key, required this.selectedField});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteController noteController = NoteController();
  final SubjectController subjectController = SubjectController();

  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await noteController.loadNotes(widget.selectedField);
    final subjects = await subjectController.loadSubjects(widget.selectedField);
    final subjectsByTitle = {
      for (final subject in subjects)
        subject['title']?.toString() ?? '': subject,
    };
    final notesWithCovers = data.map((note) {
      final subject = subjectsByTitle[note['subject']?.toString() ?? ''];

      return {
        ...note,
        'coverColor': subject?['coverColor'],
        'coverPattern': subject?['coverPattern'],
      };
    }).toList();

    if (!mounted) return;

    setState(() {
      notes = notesWithCovers;
    });
  }

  Future<void> openNote(Map<String, dynamic> note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectNoteScreen(
          subjectTitle: note['subject']?.toString() ?? '',
          selectedField: widget.selectedField,
          noteType: note['noteType']?.toString() ?? 'Blank Note',
        ),
      ),
    );

    loadNotes();
  }

  Future<void> deleteNote(Map<String, dynamic> note) async {
    await noteController.deleteNote(
      note['subject']?.toString() ?? '',
      widget.selectedField,
    );

    loadNotes();
  }

  String notePreview(Map<String, dynamic> note) {
    final content = note['content']?.toString().trim() ?? '';
    final drawing = note['drawing']?.toString() ?? '';

    if (content.isNotEmpty) {
      return content.length > 90 ? '${content.substring(0, 90)}...' : content;
    }

    if (drawing.isNotEmpty && drawing != '[]') {
      return 'Drawing note';
    }

    return 'Empty note';
  }

  Widget buildNoteCard(Map<String, dynamic> note) {
    final title = note['subject']?.toString() ?? '';
    final cover = NotebookCoverStyles.byColorAndPattern(
      note['coverColor'] is int ? note['coverColor'] as int : null,
      note['coverPattern']?.toString(),
      title,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openNote(note),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 86,
                child: NotebookCover(
                  title: title,
                  subtitle: note['noteType']?.toString() ?? 'Blank Note',
                  cover: cover,
                  height: 110,
                  compact: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note['noteType']?.toString() ?? 'Blank Note',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notePreview(note),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete note',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => deleteNote(note),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedField} Notes')),
      body: notes.isEmpty
          ? const Center(
              child: Text('No notes added yet', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) => buildNoteCard(notes[index]),
            ),
    );
  }
}

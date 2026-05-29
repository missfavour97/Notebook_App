import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import 'subject_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final String selectedField;

  const NotesScreen({super.key, required this.selectedField});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteController noteController = NoteController();

  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await noteController.loadNotes(widget.selectedField);

    if (!mounted) return;

    setState(() {
      notes = data;
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
              itemBuilder: (context, index) {
                final note = notes[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.note),
                    title: Text(note['subject']?.toString() ?? ''),
                    subtitle: Text(
                      '${note['noteType'] ?? 'Blank Note'} - ${notePreview(note)}',
                    ),
                    onTap: () => openNote(note),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteNote(note),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

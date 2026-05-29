import 'package:flutter/material.dart';
import 'subject_note_screen.dart';
import '../controllers/note_controller.dart';
import '../controllers/subject_controller.dart';

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

    setState(() {
      subjects = data;
    });
  }

  Future<void> addSubjectDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter subject name'),
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
  }

  Future<void> editSubjectDialog(Map<String, dynamic> subject) async {
    final controller = TextEditingController(text: subject['title']);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename Subject'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new subject name',
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

                await subjectController.renameSubject(
                  subject['id'],
                  controller.text.trim(),
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
  }

  Future<void> deleteSubject(int id) async {
    await subjectController.deleteSubject(id);
    loadSubjects();
  }

  Future<void> openSubject(Map<String, dynamic> subject) async {
    final note = await noteController.loadNote(
      subject['title'],
      widget.selectedField,
    );

    if (!mounted) return;

    if (note != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectNoteScreen(
            subjectTitle: subject['title'],
            selectedField: widget.selectedField,
            noteType: note['noteType'] as String? ?? 'Blank Note',
          ),
        ),
      );
    } else {
      chooseNoteType(subject);
    }
  }

  void chooseNoteType(Map<String, dynamic> subject) {
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
                    buildNoteTypeCard(subject, 'Blank Note', Icons.crop_square),
                    buildNoteTypeCard(subject, 'Lined Note', Icons.menu),
                    buildNoteTypeCard(subject, 'Grid Note', Icons.grid_on),
                    buildNoteTypeCard(
                      subject,
                      'Template Note',
                      Icons.description,
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
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);

        await noteController.saveNote(
          subject['title'],
          widget.selectedField,
          '',
          noteType,
          '',
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectNoteScreen(
              subjectTitle: subject['title'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedField} Subjects')),
      floatingActionButton: FloatingActionButton(
        onPressed: addSubjectDialog,
        child: const Icon(Icons.add),
      ),
      body: subjects.isEmpty
          ? const Center(
              child: Text(
                'No subjects added yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];

                return Card(
                  child: ListTile(
                    title: Text(subject['title']),
                    subtitle: Text(subject['field']),
                    onTap: () {
                      openSubject(subject);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editSubjectDialog(subject),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteSubject(subject['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../controllers/reminder_controller.dart';

class RemindersScreen extends StatefulWidget {
  final String selectedField;

  const RemindersScreen({
    super.key,
    required this.selectedField,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderController reminderController = ReminderController();

  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> loadReminders() async {
    final data = await reminderController.loadReminders(widget.selectedField);

    if (!mounted) return;

    setState(() {
      reminders = data;
    });
  }

  Future<void> addReminderDialog() async {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      enableSuggestions: true,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No date selected'
                                : 'Selected Date: ${formatDate(selectedDate!.toIso8601String())}',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Choose Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter reminder title'),
                        ),
                      );
                      return;
                    }

                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please choose a date'),
                        ),
                      );
                      return;
                    }

                    await reminderController.addReminder(
                      titleController.text.trim(),
                      selectedDate!.toIso8601String(),
                      widget.selectedField,
                    );

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    await loadReminders();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminder added successfully'),
                      ),
                    );
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

  Future<void> deleteReminder(int id) async {
    await reminderController.deleteReminder(id);
    loadReminders();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedField} Reminders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addReminderDialog,
        child: const Icon(Icons.add),
      ),
      body: reminders.isEmpty
          ? const Center(
        child: Text(
          'No reminders added yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(reminder['title']),
              subtitle: Text(
                'Date: ${formatDate(reminder['reminderDate'])}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteReminder(reminder['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
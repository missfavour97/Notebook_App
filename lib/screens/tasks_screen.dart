import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';

class TasksScreen extends StatefulWidget {
  final String selectedField;

  const TasksScreen({
    super.key,
    required this.selectedField,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskController taskController = TaskController();

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final data = await taskController.loadTasks(widget.selectedField);

    setState(() {
      tasks = data;
    });
  }

  Future<void> addTaskDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter task name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                await taskController.addTask(
                  controller.text.trim(),
                  widget.selectedField,
                );

                if (!mounted) return;

                Navigator.pop(context);
                loadTasks();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleTask(Map<String, dynamic> task) async {
    final isCompleted = task['isCompleted'] == 1;

    await taskController.toggleTask(
      task['id'],
      !isCompleted,
    );

    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await taskController.deleteTask(id);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedField} Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'No tasks added yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isCompleted = task['isCompleted'] == 1;

          return Card(
            child: ListTile(
              leading: Checkbox(
                value: isCompleted,
                onChanged: (_) => toggleTask(task),
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(widget.selectedField),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteTask(task['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
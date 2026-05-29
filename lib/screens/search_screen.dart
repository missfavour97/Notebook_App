import 'package:flutter/material.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends StatefulWidget {
  final String selectedField;

  const SearchScreen({super.key, required this.selectedField});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AppSearchController searchController = AppSearchController();
  final TextEditingController queryController = TextEditingController();

  List<Map<String, dynamic>> results = [];

  Future<void> runSearch(String query) async {
    final data = await searchController.searchAll(query, widget.selectedField);

    if (!mounted) return;

    setState(() {
      results = data;
    });
  }

  IconData getIcon(String type) {
    if (type == 'Subject') return Icons.menu_book;
    if (type == 'Note') return Icons.note;
    if (type == 'Task') return Icons.check_circle;
    if (type == 'Reminder') return Icons.alarm;

    return Icons.search;
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedField} Search')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: queryController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              enableSuggestions: true,
              autocorrect: true,
              decoration: const InputDecoration(
                labelText: 'Search subjects, notes, tasks, reminders',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: runSearch,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'No search results',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];

                        return Card(
                          child: ListTile(
                            leading: Icon(getIcon(item['type'])),
                            title: Text(item['title']?.toString() ?? ''),
                            subtitle: Text(item['subtitle']?.toString() ?? ''),
                            trailing: Chip(
                              label: Text(item['type']?.toString() ?? ''),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

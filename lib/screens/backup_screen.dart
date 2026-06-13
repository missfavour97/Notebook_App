import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../repositories/backup_repository.dart';

class BackupScreen extends StatefulWidget {
  final String selectedField;

  const BackupScreen({super.key, required this.selectedField});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupRepository backupRepository = BackupRepository();

  NotebookBackup? backup;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBackup();
  }

  Future<void> loadBackup() async {
    final result = await backupRepository.exportField(widget.selectedField);

    if (!mounted) return;

    setState(() {
      backup = result;
      isLoading = false;
    });
  }

  Future<void> copyBackup() async {
    final currentBackup = backup;

    if (currentBackup == null) return;

    await Clipboard.setData(ClipboardData(text: currentBackup.toPrettyJson()));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Backup copied')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.selectedField} Backup')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : backup == null
          ? _buildUnavailableState(context)
          : LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 900
                    ? 28.0
                    : 16.0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    24,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(colorScheme),
                            const SizedBox(height: 16),
                            _buildCountGrid(),
                            const SizedBox(height: 16),
                            _buildBackupStatus(colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  bool get _hasBackupData {
    final currentBackup = backup;

    if (currentBackup == null) return false;

    return currentBackup.subjectCount +
            currentBackup.noteCount +
            currentBackup.taskCount +
            currentBackup.reminderCount >
        0;
  }

  Widget _buildUnavailableState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 46,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No active account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final currentBackup = backup!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return Container(
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.inventory_2, color: colorScheme.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Vault',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: isCompact ? 22 : 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentBackup.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isCompact)
                IconButton.filled(
                  tooltip: 'Copy backup',
                  onPressed: copyBackup,
                  icon: const Icon(Icons.copy),
                )
              else
                FilledButton.icon(
                  onPressed: copyBackup,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy backup'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountGrid() {
    final currentBackup = backup!;
    final cards = [
      _BackupCountCard(
        icon: Icons.menu_book,
        label: 'Subjects',
        count: currentBackup.subjectCount,
      ),
      _BackupCountCard(
        icon: Icons.note,
        label: 'Notes',
        count: currentBackup.noteCount,
      ),
      _BackupCountCard(
        icon: Icons.check_circle,
        label: 'Tasks',
        count: currentBackup.taskCount,
      ),
      _BackupCountCard(
        icon: Icons.alarm,
        label: 'Reminders',
        count: currentBackup.reminderCount,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 620 ? 2 : 4;

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 86,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }

  Widget _buildBackupStatus(ColorScheme colorScheme) {
    final hasData = _hasBackupData;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(Icons.folder_open, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData ? 'Backup is ready' : 'No saved notebook data yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasData
                      ? 'Copy this backup and keep it somewhere safe. It includes your subjects, notes, tasks, and reminders for ${widget.selectedField}.'
                      : 'Create a subject or note first, then come back here to copy a useful backup.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: copyBackup,
            icon: const Icon(Icons.copy),
            label: Text(hasData ? 'Copy backup' : 'Copy empty backup'),
          ),
        ],
      ),
    );
  }
}

class _BackupCountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _BackupCountCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

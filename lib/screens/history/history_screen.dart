import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/track_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Clear'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear history?'),
                  content: const Text('This will remove all your listening history.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        ref.read(historyProvider.notifier).clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No history yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Your recently played songs will appear here.', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) => TrackTile(
                track: history[i],
                queue: history,
                queueIndex: i,
              ),
            ),
    );
  }
}

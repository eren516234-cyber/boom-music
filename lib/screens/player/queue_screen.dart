import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final queue = state.queue;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: ref.read(playerProvider.notifier).toggleShuffle,
            color: state.isShuffle ? theme.colorScheme.primary : null,
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Clear'),
          ),
        ],
      ),
      body: queue.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music_rounded, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Queue is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: queue.length,
              itemBuilder: (_, i) {
                final track = queue[i];
                final isCurrent = i == state.queueIndex;
                return ListTile(
                  key: ValueKey(track.id + i.toString()),
                  tileColor: isCurrent ? theme.colorScheme.primary.withOpacity(0.1) : null,
                  leading: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: track.thumbnail,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 44, height: 44,
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    track.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? theme.colorScheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(track.durationString, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => ref.read(playerProvider.notifier).removeFromQueue(i),
                      ),
                    ],
                  ),
                  onTap: () => ref.read(playerProvider.notifier).playQueue(queue, i),
                );
              },
              onReorder: (oldIndex, newIndex) {},
            ),
    );
  }
}

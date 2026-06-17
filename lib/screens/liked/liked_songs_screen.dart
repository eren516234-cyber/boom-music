import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/track_tile.dart';

class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedSongsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Songs'),
        actions: [
          if (liked.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () {
                ref.read(playerProvider.notifier).toggleShuffle();
                ref.read(playerProvider.notifier).playQueue(liked, 0);
              },
            ),
        ],
      ),
      body: liked.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No liked songs yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Tap ♥ on any track to save it here.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text('${liked.length} songs', style: TextStyle(color: Colors.grey[600])),
                      const Spacer(),
                      FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play all'),
                        onPressed: () => ref.read(playerProvider.notifier).playQueue(liked, 0),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: liked.length,
                    itemBuilder: (_, i) => TrackTile(
                      track: liked[i],
                      queue: liked,
                      queueIndex: i,
                      showIndex: true,
                      index: i,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

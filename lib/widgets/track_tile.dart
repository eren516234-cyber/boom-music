import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_models.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';

class TrackTile extends ConsumerWidget {
  final Track track;
  final List<Track>? queue;
  final int? queueIndex;
  final VoidCallback? onTap;
  final bool showIndex;
  final int? index;
  final bool showDelete;
  final VoidCallback? onDelete;

  const TrackTile({
    super.key,
    required this.track,
    this.queue,
    this.queueIndex,
    this.onTap,
    this.showIndex = false,
    this.index,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLiked = ref.watch(likedSongsProvider.notifier).isLiked(track.id);
    final currentTrack = ref.watch(playerProvider).currentTrack;
    final isPlaying = currentTrack?.id == track.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIndex && index != null)
            SizedBox(
              width: 28,
              child: Text(
                '${index! + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isPlaying ? theme.colorScheme.primary : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: track.thumbnail,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: theme.colorScheme.primaryContainer,
                child: const Icon(Icons.music_note, size: 20),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        track.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isPlaying ? theme.colorScheme.primary : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.durationString,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: isLiked ? theme.colorScheme.primary : Colors.grey[400],
            ),
            onPressed: () => ref.read(likedSongsProvider.notifier).toggle(track),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          if (showDelete)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey[400]),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ],
      ),
      onTap: onTap ?? () {
        ref.read(playerProvider.notifier).play(
              track,
              queue: queue,
              index: queueIndex,
            );
      },
    );
  }
}

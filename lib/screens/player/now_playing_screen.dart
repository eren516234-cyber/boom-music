import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/music_models.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final track = state.currentTrack;
    final theme = Theme.of(context);

    if (track == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Nothing playing')),
      );
    }

    final isLiked = ref.watch(likedSongsProvider.notifier).isLiked(track.id);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => context.pop(),
        ),
        title: const Text('Now Playing', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showOptions(context, ref, track),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(flex: 2),

          // Artwork
          Hero(
            tag: 'now_playing_art',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: track.thumbnail,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.music_note_rounded, size: 80),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Track info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.artist,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? theme.colorScheme.primary : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () => ref.read(likedSongsProvider.notifier).toggle(track),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ProgressBar(state: state),
          ),

          const SizedBox(height: 8),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Controls(state: state),
          ),

          const Spacer(flex: 1),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionBtn(Icons.lyrics_outlined, 'Lyrics', () => context.push('/lyrics')),
                _ActionBtn(Icons.queue_music_rounded, 'Queue', () => context.push('/queue')),
                _ActionBtn(Icons.share_outlined, 'Share', () {}),
                _ActionBtn(Icons.equalizer_rounded, 'EQ', () => context.push('/eq')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Track track) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Add to playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_to_queue_rounded),
              title: const Text('Add to queue'),
              onTap: () {
                ref.read(playerProvider.notifier).addToQueue(track);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  final PlayerState state;
  const _ProgressBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = state.position.inSeconds.toDouble();
    final dur = state.duration.inSeconds.toDouble();
    final safeMax = dur > 0 ? dur : 1.0;
    final safePOS = pos.clamp(0.0, safeMax);

    return Column(
      children: [
        Slider(
          value: safePOS,
          min: 0,
          max: safeMax,
          onChanged: (v) => ref.read(playerProvider.notifier).seek(Duration(seconds: v.toInt())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(state.position), style: const TextStyle(fontSize: 12)),
              Text(_fmt(state.duration), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _Controls extends ConsumerWidget {
  final PlayerState state;
  const _Controls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: state.isShuffle ? theme.colorScheme.primary : Colors.grey,
          ),
          onPressed: notifier.toggleShuffle,
          iconSize: 24,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: notifier.previous,
          iconSize: 36,
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
            onPressed: notifier.togglePlay,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: notifier.next,
          iconSize: 36,
        ),
        IconButton(
          icon: Icon(
            state.repeatMode == RepeatMode.none
                ? Icons.repeat_rounded
                : state.repeatMode == RepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
            color: state.repeatMode != RepeatMode.none ? theme.colorScheme.primary : Colors.grey,
          ),
          onPressed: notifier.toggleRepeat,
          iconSize: 24,
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

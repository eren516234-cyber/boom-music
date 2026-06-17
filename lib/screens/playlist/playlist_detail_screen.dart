import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/music_models.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/track_tile.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const PlaylistDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  String _filter = '';
  bool _showMenu = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(localPlaylistsProvider);
    final playlist = playlists.firstWhere(
      (p) => p.id == widget.id,
      orElse: () => const Playlist(id: '', title: 'Playlist', thumbnail: '', source: 'local'),
    );
    final theme = Theme.of(context);

    final tracks = _getMockTracks(playlist.id);
    final filtered = _filter.isEmpty
        ? tracks
        : tracks.where((t) =>
            t.title.toLowerCase().contains(_filter.toLowerCase()) ||
            t.artist.toLowerCase().contains(_filter.toLowerCase())).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: playlist.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.primaryContainer),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, theme.scaffoldBackgroundColor],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  if (playlist.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(playlist.description, style: TextStyle(color: Colors.grey[600])),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                        onPressed: tracks.isNotEmpty
                            ? () => ref.read(playerProvider.notifier).playQueue(tracks, 0)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.more_horiz_rounded),
                            label: const Text('More'),
                            onPressed: () => setState(() => _showMenu = !_showMenu),
                          ),
                          if (_showMenu)
                            Positioned(
                              top: 44,
                              left: 0,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    children: [
                                      _MenuItem(Icons.add_to_queue_rounded, 'Add to queue', () {
                                        for (final t in tracks) ref.read(playerProvider.notifier).addToQueue(t);
                                        setState(() => _showMenu = false);
                                      }),
                                      _MenuItem(Icons.download_for_offline_rounded, 'Export as JSON', () => setState(() => _showMenu = false)),
                                      _MenuItem(Icons.delete_outline_rounded, 'Delete playlist', () {
                                        ref.read(localPlaylistsProvider.notifier).delete(playlist.id);
                                        Navigator.pop(context);
                                      }, isDestructive: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Filter tracks',
                  prefixIcon: const Icon(Icons.filter_list_rounded),
                  suffixIcon: _filter.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _filter = ''))
                      : null,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(child: Text('Artist', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  const SizedBox(width: 40),
                  const Expanded(child: Text('Title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  const SizedBox(width: 60),
                  Text('Duration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => TrackTile(
                track: filtered[i],
                queue: filtered,
                queueIndex: i,
                showDelete: true,
                onDelete: () {},
              ),
              childCount: filtered.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<Track> _getMockTracks(String playlistId) {
    return List.generate(
      12,
      (i) => Track(
        id: '${playlistId}_track_$i',
        title: ['Chicago Streets', 'Dont Want This to End', 'Workflow', 'Cabin Glow', 'Dusty Streets', 'MUTED', 'Sandcastles', 'Nectarine No. 8', 'Impasse', 'Soft Landing', 'Blue Reverie', 'Grain & Light'][i % 12],
        artist: ['Erwin Do', 'Prospective', 'Gianni', 'sloh rou', 'Sineg', 'Philanthrope', 'LUXID AXID', 'Flitz&Suppe', 'mell-ø', 'Neon Cascade', 'Glass Orchard', 'Luna Wren'][i % 12],
        thumbnail: 'https://picsum.photos/seed/${playlistId.hashCode + i}/300/300',
        duration: 90 + i * 7,
        source: 'local',
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuItem(this.icon, this.label, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : null;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 14)),
      onTap: onTap,
    );
  }
}

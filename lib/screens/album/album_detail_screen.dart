import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/music_models.dart';
import '../../providers/player_provider.dart';
import '../../widgets/track_tile.dart';
import '../../services/deezer_service.dart';

final _albumProvider = FutureProvider.family<Album?, String>((ref, id) async {
  return DeezerService().getAlbum(id);
});

class AlbumDetailScreen extends ConsumerWidget {
  final String id;
  const AlbumDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(_albumProvider(id));
    final theme = Theme.of(context);

    return albumAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Album')),
        body: Center(child: _mockAlbumView(context, ref, theme)),
      ),
      data: (album) => album == null
          ? Scaffold(appBar: AppBar(title: const Text('Album')), body: Center(child: _mockAlbumView(context, ref, theme)))
          : _AlbumView(album: album),
    );
  }

  Widget _mockAlbumView(BuildContext context, WidgetRef ref, ThemeData theme) {
    final album = Album(
      id: id,
      title: 'Signal & Noise',
      artist: 'Moth & Signal',
      thumbnail: 'https://picsum.photos/seed/${id.hashCode}/400/400',
      year: 2024,
      trackCount: 10,
      source: 'youtube',
      tracks: List.generate(10, (i) => Track(
        id: '${id}_t$i',
        title: ['Wing Beat Frequency', 'Antenna', 'Still Waters Run Code', 'Circuit Ghost', 'Dust Trail', 'Static Mirror', 'Frequency Loss', 'Carrier Signal', 'Radio Quiet', 'Signal Return'][i],
        artist: 'Moth & Signal',
        thumbnail: 'https://picsum.photos/seed/${id.hashCode}/400/400',
        duration: 180 + i * 15,
        source: 'youtube',
      )),
    );
    return _AlbumView(album: album);
  }
}

class _AlbumView extends ConsumerWidget {
  final Album album;
  const _AlbumView({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: album.thumbnail,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(album.artist, style: TextStyle(fontSize: 16, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  if (album.year != null)
                    Text('${album.year} · ${album.trackCount ?? 0} tracks', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                        onPressed: album.tracks.isNotEmpty
                            ? () => ref.read(playerProvider.notifier).playQueue(album.tracks, 0)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle'),
                        onPressed: album.tracks.isNotEmpty
                            ? () {
                                ref.read(playerProvider.notifier).toggleShuffle();
                                ref.read(playerProvider.notifier).playQueue(album.tracks, 0);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => TrackTile(
                track: album.tracks[i],
                queue: album.tracks,
                queueIndex: i,
                showIndex: true,
                index: i,
              ),
              childCount: album.tracks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/music_models.dart';
import '../../providers/player_provider.dart';
import '../../services/deezer_service.dart';
import '../../widgets/album_card.dart';
import '../../widgets/track_tile.dart';

final _artistProvider = FutureProvider.family<Artist?, String>((ref, id) => DeezerService().getArtist(id));

class ArtistDetailScreen extends ConsumerWidget {
  final String id;
  const ArtistDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(_artistProvider(id));
    return artistAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (_, __) => _ArtistView(artist: _mockArtist(id)),
      data: (a) => _ArtistView(artist: a ?? _mockArtist(id)),
    );
  }

  Artist _mockArtist(String id) => Artist(
        id: id,
        name: 'Neon Cascade',
        thumbnail: 'https://picsum.photos/seed/${id.hashCode}/400/400',
        banner: 'https://picsum.photos/seed/${id.hashCode + 1}/1200/400',
        bio: 'Electronic artist known for dreamy synth-pop soundscapes. Based in Tokyo.',
        followers: 124500,
        source: 'youtube',
      );
}

class _ArtistView extends ConsumerWidget {
  final Artist artist;
  const _ArtistView({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mockTracks = List.generate(8, (i) => Track(
      id: '${artist.id}_t$i',
      title: ['Phosphor Gate', 'Dissolve the Grid', 'Neon Bloom', 'Signal Return', 'Circuit Dawn', 'Cascade', 'Static Bloom', 'Grid Walk'][i],
      artist: artist.name,
      thumbnail: 'https://picsum.photos/seed/${artist.id.hashCode + i}/300/300',
      duration: 200 + i * 20,
      source: artist.source,
    ));
    final mockAlbums = List.generate(4, (i) => Album(
      id: '${artist.id}_alb$i',
      title: ['Neon Dreams', 'Grid Static', 'Signal Loss', 'Cascade EP'][i],
      artist: artist.name,
      thumbnail: 'https://picsum.photos/seed/${artist.id.hashCode + i + 10}/300/300',
      year: 2020 + i,
      source: artist.source,
    ));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: artist.banner ?? artist.thumbnail,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: theme.colorScheme.primaryContainer),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(artist.thumbnail),
                        onBackgroundImageError: (_, __) {},
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(artist.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                            if (artist.followers != null)
                              Text(
                                '${_fmt(artist.followers!)} followers',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                      FilledButton(onPressed: () {}, child: const Text('Follow')),
                    ],
                  ),
                  if (artist.bio != null) ...[
                    const SizedBox(height: 12),
                    Text(artist.bio!, style: TextStyle(color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
          ),
          // Top Tracks
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('Top Tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => TrackTile(track: mockTracks[i], queue: mockTracks, queueIndex: i, showIndex: true, index: i),
              childCount: mockTracks.length,
            ),
          ),
          // Albums
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Discography', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: mockAlbums.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => AlbumCard(album: mockAlbums[i]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

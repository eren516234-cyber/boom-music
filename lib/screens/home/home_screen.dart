import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/music_models.dart';
import '../../providers/search_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  int _albumPage = 0;
  int _releasePage = 0;
  int _playlistPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: homeData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorWidget(error: e, onRetry: () => ref.invalidate(homeDataProvider)),
        data: (data) => Row(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(homeDataProvider),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Top Tracks horizontal scroll
                    if (data.topTracks.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Top Tracks',
                          badge: data.source,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 170,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: data.topTracks.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => _TrackCard(
                              track: data.topTracks[i],
                              queue: data.topTracks,
                              index: i,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Top Albums
                    if (data.topAlbums.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Top Albums',
                          badge: data.source,
                          onPrevious: _albumPage > 0 ? () => setState(() => _albumPage--) : null,
                          onNext: () => setState(() => _albumPage++),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: data.topAlbums.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => AlbumCard(
                              album: data.topAlbums[i],
                              onTap: () => context.push('/album/${data.topAlbums[i].id}'),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // New Releases
                    if (data.newReleases.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'New Releases',
                          badge: data.source,
                          onPrevious: _releasePage > 0 ? () => setState(() => _releasePage--) : null,
                          onNext: () => setState(() => _releasePage++),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: data.newReleases.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => AlbumCard(
                              album: data.newReleases[i],
                              onTap: () => context.push('/album/${data.newReleases[i].id}'),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Top Playlists
                    if (data.topPlaylists.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Featured Playlists',
                          badge: data.source,
                          onPrevious: _playlistPage > 0 ? () => setState(() => _playlistPage--) : null,
                          onNext: () => setState(() => _playlistPage++),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: data.topPlaylists.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => PlaylistCard(
                              playlist: data.topPlaylists[i],
                              onTap: () => context.push('/playlist/${data.topPlaylists[i].id}'),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),

            // Right queue panel (on wider screens)
            if (MediaQuery.of(context).size.width > 700)
              _QueuePanel(tracks: data.topTracks),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends ConsumerWidget {
  final Track track;
  final List<Track> queue;
  final int index;

  const _TrackCard({required this.track, required this.queue, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).play(track, queue: queue, index: index),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                track.thumbnail,
                width: 140,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 140,
                  height: 110,
                  color: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.music_note, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(track.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(track.artist, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _QueuePanel extends ConsumerWidget {
  final List<Track> tracks;
  const _QueuePanel({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(tracks[i].thumbnail, width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 36, height: 36, color: theme.colorScheme.primaryContainer)),
                ),
                title: Text(tracks[i].title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(tracks[i].artist, style: const TextStyle(fontSize: 11), maxLines: 1),
                trailing: Text(tracks[i].durationString, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                onTap: () => ref.read(playerProvider.notifier).play(tracks[i], queue: tracks, index: i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Could not load music', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Check your internet connection', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

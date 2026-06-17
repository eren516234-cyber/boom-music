import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/music_models.dart';
import '../../providers/search_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/track_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _query.isNotEmpty ? ref.watch(searchResultsProvider(_query)) : null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onSubmitted: (v) => setState(() => _query = v.trim()),
          textInputAction: TextInputAction.search,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_query.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('Query: "$_query"', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Tracks'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
            ),
          ],
          Expanded(
            child: _query.isEmpty
                ? _SearchSuggestions(onSuggestion: (s) {
                    _controller.text = s;
                    setState(() => _query = s);
                  })
                : results == null
                    ? const SizedBox()
                    : results.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text('Search failed. Try again.')),
                        data: (data) => TabBarView(
                          controller: _tabs,
                          children: [
                            _TrackResults(tracks: data.tracks),
                            _AlbumResults(albums: data.albums),
                            _ArtistResults(artists: data.artists),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TrackResults extends ConsumerWidget {
  final List<Track> tracks;
  const _TrackResults({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tracks.isEmpty) return const Center(child: Text('No tracks found'));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton.filled(
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: () => ref.read(playerProvider.notifier).playQueue(tracks, 0),
                style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                icon: const Icon(Icons.add_rounded),
                onPressed: () {
                  for (final t in tracks) {
                    ref.read(playerProvider.notifier).addToQueue(t);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added all to queue')),
                  );
                },
                style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (_, i) => TrackTile(
              track: tracks[i],
              queue: tracks,
              queueIndex: i,
              showIndex: true,
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumResults extends StatelessWidget {
  final List<Album> albums;
  const _AlbumResults({required this.albums});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const Center(child: Text('No albums found'));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (_, i) => AlbumCard(
        album: albums[i],
        width: double.infinity,
        onTap: () => context.push('/album/${albums[i].id}'),
      ),
    );
  }
}

class _ArtistResults extends StatelessWidget {
  final List<Artist> artists;
  const _ArtistResults({required this.artists});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const Center(child: Text('No artists found'));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: artists.length,
      itemBuilder: (_, i) => ArtistCard(
        artist: artists[i],
        width: double.infinity,
        onTap: () => context.push('/artist/${artists[i].id}'),
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final void Function(String) onSuggestion;
  const _SearchSuggestions({required this.onSuggestion});

  static const _suggestions = [
    'Neon Cascade', 'Lofi Beats', 'Chill Vibes', 'Midnight Jazz',
    'Electronic', 'Acoustic Guitar', 'Study Music', 'Workout Hits',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popular searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestions
                .map((s) => ActionChip(
                      label: Text(s),
                      onPressed: () => onSuggestion(s),
                      avatar: const Icon(Icons.trending_up_rounded, size: 16),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_models.dart';
import '../services/youtube_music_service.dart';
import '../services/deezer_service.dart';
import '../services/audius_service.dart';
import '../services/jiosaavn_service.dart';
import 'theme_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchTabProvider = StateProvider<int>((ref) => 0);

final searchResultsProvider = FutureProvider.family<SearchResults, String>((ref, query) async {
  if (query.isEmpty) return const SearchResults();
  final source = ref.watch(apiSourceProvider);
  return switch (source) {
    'deezer' => DeezerService().search(query),
    'audius' => AudiusService().search(query),
    'jiosaavn' => JioSaavnService().search(query),
    _ => YouTubeMusicService().search(query),
  };
});

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final source = ref.watch(apiSourceProvider);
  if (source == 'deezer') {
    final deezer = DeezerService();
    final results = await Future.wait([
      deezer.getTopTracks(),
      deezer.getTopAlbums(),
      deezer.getTopPlaylists(),
    ]);
    final tracks = results[0] as List<Track>;
    final albums = results[1] as List<Album>;
    final playlists = results[2] as List<Playlist>;
    return HomeData(
      topTracks: tracks,
      topAlbums: albums,
      newReleases: albums.reversed.toList(),
      topPlaylists: playlists,
      source: 'Deezer',
    );
  } else if (source == 'audius') {
    final audius = AudiusService();
    final results = await Future.wait([
      audius.getTrendingTracks(),
      audius.getFeaturedPlaylists(),
    ]);
    final tracks = results[0] as List<Track>;
    final playlists = results[1] as List<Playlist>;
    return HomeData(
      topTracks: tracks,
      topPlaylists: playlists,
      source: 'Audius',
    );
  }
  final yt = YouTubeMusicService();
  final results = await Future.wait([
    yt.getTopTracks(),
    yt.getTopAlbums(),
    yt.getNewReleases(),
  ]);
  final tracks = results[0] as List<Track>;
  final albums = results[1] as List<Album>;
  final newReleases = results[2] as List<Album>;
  return HomeData(
    topTracks: tracks,
    topAlbums: albums,
    newReleases: newReleases,
    source: 'YouTube Music',
  );
});

class HomeData {
  final List<Track> topTracks;
  final List<Album> topAlbums;
  final List<Album> newReleases;
  final List<Playlist> topPlaylists;
  final String source;

  const HomeData({
    this.topTracks = const [],
    this.topAlbums = const [],
    this.newReleases = const [],
    this.topPlaylists = const [],
    required this.source,
  });
}

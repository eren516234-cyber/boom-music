import 'package:dio/dio.dart';
import '../models/music_models.dart';

class AudiusService {
  static const _baseUrl = 'https://discoveryprovider.audius.co/v1';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    queryParameters: {'app_name': 'BoomMusic'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SearchResults> search(String query) async {
    try {
      final [tracksResp, albumsResp, artistsResp] = await Future.wait([
        _dio.get('/tracks/search', queryParameters: {'query': query, 'limit': 20}),
        _dio.get('/playlists/search', queryParameters: {'query': query, 'limit': 10}),
        _dio.get('/users/search', queryParameters: {'query': query, 'limit': 6}),
      ]);

      final tracks = ((tracksResp.data['data'] ?? []) as List)
          .map((t) => Track(
                id: t['id'] ?? '',
                title: t['title'] ?? '',
                artist: t['user']?['name'] ?? '',
                artistId: t['user']?['id'] ?? '',
                thumbnail: t['artwork']?['_480x480'] ?? t['artwork']?['_150x150'] ?? '',
                duration: t['duration'] ?? 0,
                source: 'audius',
                streamUrl: '$_baseUrl/tracks/${t['id']}/stream?app_name=BoomMusic',
              ))
          .toList();

      final playlists = ((albumsResp.data['data'] ?? []) as List)
          .map((p) => Playlist(
                id: p['id'] ?? '',
                title: p['playlist_name'] ?? '',
                thumbnail: p['artwork']?['_480x480'] ?? '',
                trackCount: p['track_count'] ?? 0,
                source: 'audius',
              ))
          .toList();

      final artists = ((artistsResp.data['data'] ?? []) as List)
          .map((u) => Artist(
                id: u['id'] ?? '',
                name: u['name'] ?? '',
                thumbnail: u['profile_picture']?['_480x480'] ?? '',
                followers: u['follower_count'],
                source: 'audius',
              ))
          .toList();

      return SearchResults(tracks: tracks, playlists: playlists, artists: artists);
    } catch (_) {
      return const SearchResults();
    }
  }

  Future<List<Track>> getTrendingTracks() async {
    try {
      final resp = await _dio.get('/tracks/trending', queryParameters: {'limit': 20});
      return ((resp.data['data'] ?? []) as List)
          .map((t) => Track(
                id: t['id'] ?? '',
                title: t['title'] ?? '',
                artist: t['user']?['name'] ?? '',
                thumbnail: t['artwork']?['_480x480'] ?? t['artwork']?['_150x150'] ?? '',
                duration: t['duration'] ?? 0,
                source: 'audius',
                streamUrl: '$_baseUrl/tracks/${t['id']}/stream?app_name=BoomMusic',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Playlist>> getFeaturedPlaylists() async {
    try {
      final resp = await _dio.get('/playlists/trending', queryParameters: {'limit': 10});
      return ((resp.data['data'] ?? []) as List)
          .map((p) => Playlist(
                id: p['id'] ?? '',
                title: p['playlist_name'] ?? '',
                thumbnail: p['artwork']?['_480x480'] ?? '',
                trackCount: p['track_count'] ?? 0,
                source: 'audius',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> getStreamUrl(String trackId) async {
    return '$_baseUrl/tracks/$trackId/stream?app_name=BoomMusic';
  }
}

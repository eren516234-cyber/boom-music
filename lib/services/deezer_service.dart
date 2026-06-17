import 'package:dio/dio.dart';
import '../models/music_models.dart';

class DeezerService {
  static const _baseUrl = 'https://api.deezer.com';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SearchResults> search(String query) async {
    try {
      final [tracksResp, albumsResp, artistsResp] = await Future.wait([
        _dio.get('/search/track', queryParameters: {'q': query, 'limit': 20}),
        _dio.get('/search/album', queryParameters: {'q': query, 'limit': 10}),
        _dio.get('/search/artist', queryParameters: {'q': query, 'limit': 6}),
      ]);

      final tracks = ((tracksResp.data['data'] ?? []) as List)
          .map((t) => Track(
                id: '${t['id']}',
                title: t['title'] ?? '',
                artist: t['artist']?['name'] ?? '',
                artistId: '${t['artist']?['id'] ?? ''}',
                album: t['album']?['title'] ?? '',
                albumId: '${t['album']?['id'] ?? ''}',
                thumbnail: t['album']?['cover_medium'] ?? t['album']?['cover'] ?? '',
                duration: t['duration'] ?? 0,
                source: 'deezer',
                streamUrl: t['preview'],
              ))
          .toList();

      final albums = ((albumsResp.data['data'] ?? []) as List)
          .map((a) => Album(
                id: '${a['id']}',
                title: a['title'] ?? '',
                artist: a['artist']?['name'] ?? '',
                thumbnail: a['cover_medium'] ?? a['cover'] ?? '',
                source: 'deezer',
              ))
          .toList();

      final artists = ((artistsResp.data['data'] ?? []) as List)
          .map((a) => Artist(
                id: '${a['id']}',
                name: a['name'] ?? '',
                thumbnail: a['picture_medium'] ?? a['picture'] ?? '',
                source: 'deezer',
              ))
          .toList();

      return SearchResults(tracks: tracks, albums: albums, artists: artists);
    } catch (_) {
      return const SearchResults();
    }
  }

  Future<List<Track>> getTopTracks() async {
    try {
      final resp = await _dio.get('/chart/0/tracks', queryParameters: {'limit': 20});
      return ((resp.data['data'] ?? []) as List)
          .map((t) => Track(
                id: '${t['id']}',
                title: t['title'] ?? '',
                artist: t['artist']?['name'] ?? '',
                thumbnail: t['album']?['cover_medium'] ?? '',
                duration: t['duration'] ?? 0,
                source: 'deezer',
                streamUrl: t['preview'],
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Album>> getTopAlbums() async {
    try {
      final resp = await _dio.get('/chart/0/albums', queryParameters: {'limit': 10});
      return ((resp.data['data'] ?? []) as List)
          .map((a) => Album(
                id: '${a['id']}',
                title: a['title'] ?? '',
                artist: a['artist']?['name'] ?? '',
                thumbnail: a['cover_medium'] ?? '',
                source: 'deezer',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Playlist>> getTopPlaylists() async {
    try {
      final resp = await _dio.get('/chart/0/playlists', queryParameters: {'limit': 10});
      return ((resp.data['data'] ?? []) as List)
          .map((p) => Playlist(
                id: '${p['id']}',
                title: p['title'] ?? '',
                thumbnail: p['picture_medium'] ?? '',
                trackCount: p['nb_tracks'] ?? 0,
                source: 'deezer',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Album?> getAlbum(String id) async {
    try {
      final [albumResp, tracksResp] = await Future.wait([
        _dio.get('/album/$id'),
        _dio.get('/album/$id/tracks'),
      ]);
      final a = albumResp.data;
      final tracks = ((tracksResp.data['data'] ?? []) as List)
          .map((t) => Track(
                id: '${t['id']}',
                title: t['title'] ?? '',
                artist: t['artist']?['name'] ?? a['artist']?['name'] ?? '',
                thumbnail: a['cover_medium'] ?? '',
                duration: t['duration'] ?? 0,
                source: 'deezer',
                streamUrl: t['preview'],
              ))
          .toList();
      return Album(
        id: id,
        title: a['title'] ?? '',
        artist: a['artist']?['name'] ?? '',
        thumbnail: a['cover_medium'] ?? '',
        year: a['release_date'] != null ? int.tryParse(a['release_date'].toString().substring(0, 4)) : null,
        trackCount: a['nb_tracks'],
        source: 'deezer',
        tracks: tracks,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Artist?> getArtist(String id) async {
    try {
      final resp = await _dio.get('/artist/$id');
      final a = resp.data;
      return Artist(
        id: id,
        name: a['name'] ?? '',
        thumbnail: a['picture_medium'] ?? '',
        banner: a['picture_xl'],
        followers: a['nb_fan'],
        source: 'deezer',
      );
    } catch (_) {
      return null;
    }
  }
}

import 'package:dio/dio.dart';
import '../models/music_models.dart';

class YouTubeMusicService {
  static const _baseUrl = 'https://music.youtube.com/youtubei/v1';
  static const _apiKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';
  static const _headers = {
    'Content-Type': 'application/json',
    'User-Agent': 'Mozilla/5.0 (compatible; BoomMusic/1.0)',
    'Origin': 'https://music.youtube.com',
    'Referer': 'https://music.youtube.com/',
    'X-YouTube-Client-Name': '67',
    'X-YouTube-Client-Version': '1.20240101.00.00',
  };

  static const _context = {
    'client': {
      'clientName': 'WEB_REMIX',
      'clientVersion': '1.20240101.00.00',
      'hl': 'en',
      'gl': 'US',
    }
  };

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: _headers,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SearchResults> search(String query) async {
    try {
      final resp = await _dio.post(
        '/search?key=$_apiKey',
        data: {
          'context': _context,
          'query': query,
          'params': 'EgWKAQIIAWoKEAkQBRAKEAMQBA==', // all types
        },
      );

      final contents = resp.data['contents']?['tabbedSearchResultsRenderer']
              ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
          ?['contents'] as List? ?? [];

      final tracks = <Track>[];
      final albums = <Album>[];
      final artists = <Artist>[];

      for (final section in contents) {
        final items = section['musicShelfRenderer']?['contents'] as List? ?? [];
        for (final item in items) {
          final renderer = item['musicResponsiveListItemRenderer'];
          if (renderer == null) continue;

          final flexCols = renderer['flexColumns'] as List? ?? [];
          final title = _extractText(flexCols.isNotEmpty
              ? flexCols[0]['musicResponsiveListItemFlexColumnRenderer']?['text']
              : null);

          final subtitle = _extractText(flexCols.length > 1
              ? flexCols[1]['musicResponsiveListItemFlexColumnRenderer']?['text']
              : null);

          final videoId = renderer['playlistItemData']?['videoId'] ??
              renderer['overlay']?['musicItemThumbnailOverlayRenderer']
                  ?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']
                  ?['watchEndpoint']?['videoId'];

          final thumbnail = _extractThumbnail(renderer['thumbnail']);

          if (videoId != null && title.isNotEmpty) {
            tracks.add(Track(
              id: videoId,
              title: title,
              artist: subtitle,
              thumbnail: thumbnail,
              duration: 0,
              source: 'youtube',
            ));
          }
        }
      }

      return SearchResults(tracks: tracks, albums: albums, artists: artists);
    } catch (_) {
      return _mockSearchResults(query);
    }
  }

  Future<List<Track>> getTopTracks() async {
    return _mockTracks();
  }

  Future<List<Album>> getTopAlbums() async {
    return _mockAlbums();
  }

  Future<List<Album>> getNewReleases() async {
    return _mockAlbums(seed: 10);
  }

  Future<String?> getStreamUrl(String videoId) async {
    // In production: use InnerTube /player endpoint or yt-dlp
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  String _extractText(dynamic node) {
    if (node == null) return '';
    final runs = node['runs'] as List?;
    if (runs == null || runs.isEmpty) return node['simpleText'] ?? '';
    return runs.map((r) => r['text'] ?? '').join('');
  }

  String _extractThumbnail(dynamic node) {
    final thumbnails = node?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails == null || thumbnails.isEmpty) return '';
    return thumbnails.last['url'] ?? '';
  }

  // Mock data for demo when API fails
  SearchResults _mockSearchResults(String query) {
    return SearchResults(
      tracks: _mockTracks().take(10).toList(),
      albums: _mockAlbums().take(6).toList(),
      artists: _mockArtists().take(4).toList(),
    );
  }

  List<Track> _mockTracks({int seed = 0}) {
    final data = [
      ('Phosphor Dreams', 'Neon Cascade', '4:07'),
      ('Signal Return', 'Neon Cascade', '3:22'),
      ('Wing Beat Frequency', 'Moth & Signal', '3:18'),
      ('Still Waters Run Code', 'Moth & Signal', '4:51'),
      ('Paper Lanterns', 'Yuki Tanaka', '3:43'),
      ('Circuit Breaker', 'The Velvet Circuit', '5:12'),
      ('Kintsugi', 'Yuki Tanaka', '5:41'),
      ('Overload', 'The Velvet Circuit', '3:06'),
      ('Midnight FM', 'Idris Kane', '4:55'),
      ('Greenhouse', 'Glass Orchard', '4:18'),
      ('Solar Wind', 'Solaris Pulse', '5:32'),
      ('Hollow Bones', 'Luna Wren', '3:29'),
      ('Playback', 'Echo Vault', '4:27'),
      ('Antenna', 'Moth & Signal', '4:34'),
      ('Dissolve the Grid', 'Neon Cascade', '5:12'),
    ];
    return data
        .skip(seed)
        .take(10)
        .toList()
        .asMap()
        .entries
        .map((e) => Track(
              id: 'yt_mock_${seed}_${e.key}',
              title: e.value.$1,
              artist: e.value.$2,
              thumbnail: 'https://picsum.photos/seed/${seed + e.key + 1}/200/200',
              duration: _parseDuration(e.value.$3),
              source: 'youtube',
            ))
        .toList();
  }

  List<Album> _mockAlbums({int seed = 0}) {
    final data = [
      ('Neon Dreams', 'Neon Cascade', '2024'),
      ('Signal & Noise', 'Moth & Signal', '2024'),
      ('Velvet Static', 'The Velvet Circuit', '2023'),
      ('Glass Surfaces', 'Glass Orchard', '2024'),
      ('Kintsugi EP', 'Yuki Tanaka', '2023'),
      ('Midnight Sessions', 'Idris Kane', '2024'),
    ];
    return data
        .skip(seed % data.length)
        .take(6)
        .toList()
        .asMap()
        .entries
        .map((e) => Album(
              id: 'alb_${seed}_${e.key}',
              title: e.value.$1,
              artist: e.value.$2,
              thumbnail: 'https://picsum.photos/seed/${seed + e.key + 20}/300/300',
              year: int.tryParse(e.value.$3),
              source: 'youtube',
            ))
        .toList();
  }

  List<Artist> _mockArtists() {
    return [
      Artist(id: 'art_1', name: 'Neon Cascade', thumbnail: 'https://picsum.photos/seed/101/300/300', source: 'youtube'),
      Artist(id: 'art_2', name: 'Moth & Signal', thumbnail: 'https://picsum.photos/seed/102/300/300', source: 'youtube'),
      Artist(id: 'art_3', name: 'The Velvet Circuit', thumbnail: 'https://picsum.photos/seed/103/300/300', source: 'youtube'),
      Artist(id: 'art_4', name: 'Glass Orchard', thumbnail: 'https://picsum.photos/seed/104/300/300', source: 'youtube'),
      Artist(id: 'art_5', name: 'Yuki Tanaka', thumbnail: 'https://picsum.photos/seed/105/300/300', source: 'youtube'),
      Artist(id: 'art_6', name: 'Idris Kane', thumbnail: 'https://picsum.photos/seed/106/300/300', source: 'youtube'),
    ];
  }

  int _parseDuration(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

import 'package:dio/dio.dart';
import '../models/music_models.dart';

class JioSaavnService {
  static const _baseUrl = 'https://www.jiosaavn.com/api.php';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SearchResults> search(String query) async {
    try {
      final resp = await _dio.get(_baseUrl, queryParameters: {
        '__call': 'autocomplete.get',
        'query': query,
        '_format': 'json',
        '_marker': '0',
        'ctx': 'wap6dot0',
      });
      final data = resp.data;
      final songs = (data['songs']?['data'] as List? ?? [])
          .map((s) => Track(
                id: s['id'] ?? '',
                title: _cleanHtml(s['title'] ?? ''),
                artist: _cleanHtml(s['more_info']?['singers'] ?? s['description'] ?? ''),
                album: _cleanHtml(s['more_info']?['album'] ?? ''),
                thumbnail: (s['image'] ?? '').replaceAll('150x150', '500x500'),
                duration: int.tryParse(s['more_info']?['duration'] ?? '0') ?? 0,
                source: 'jiosaavn',
              ))
          .toList();
      return SearchResults(tracks: songs);
    } catch (_) {
      return const SearchResults();
    }
  }

  Future<List<Track>> getTopSongs() async {
    try {
      final resp = await _dio.get(_baseUrl, queryParameters: {
        '__call': 'content.getBrowseModules',
        '_format': 'json',
        '_marker': '0',
        'ctx': 'wap6dot0',
      });
      return [];
    } catch (_) {
      return [];
    }
  }

  String _cleanHtml(String s) =>
      s.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&amp;', '&').replaceAll('&#039;', "'");
}

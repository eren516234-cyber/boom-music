import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/music_models.dart';

final likedSongsProvider = StateNotifierProvider<LikedSongsNotifier, List<Track>>((ref) {
  return LikedSongsNotifier();
});

class LikedSongsNotifier extends StateNotifier<List<Track>> {
  LikedSongsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box('liked_songs');
    final raw = box.values.toList();
    state = raw.map((e) => Track.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
  }

  void toggle(Track track) {
    final box = Hive.box('liked_songs');
    final exists = state.any((t) => t.id == track.id);
    if (exists) {
      box.delete(track.id);
      state = state.where((t) => t.id != track.id).toList();
    } else {
      track.isLiked = true;
      box.put(track.id, jsonEncode(track.toJson()));
      state = [...state, track];
    }
  }

  bool isLiked(String id) => state.any((t) => t.id == id);
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Track>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<Track>> {
  HistoryNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box('history');
    final raw = box.values.toList();
    state = raw.map((e) => Track.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList().reversed.toList();
  }

  void add(Track track) {
    final box = Hive.box('history');
    box.put('${DateTime.now().millisecondsSinceEpoch}', jsonEncode(track.toJson()));
    state = [track, ...state.where((t) => t.id != track.id).take(99)];
  }

  void clear() {
    Hive.box('history').clear();
    state = [];
  }
}

final localPlaylistsProvider = StateNotifierProvider<LocalPlaylistsNotifier, List<Playlist>>((ref) {
  return LocalPlaylistsNotifier();
});

class LocalPlaylistsNotifier extends StateNotifier<List<Playlist>> {
  LocalPlaylistsNotifier() : super(_mockPlaylists());

  static List<Playlist> _mockPlaylists() => [
        const Playlist(
          id: 'pl_study_lofi',
          title: 'Study Lofi',
          description: 'A selection of chill beats to help you study.',
          thumbnail: 'https://picsum.photos/seed/pl1/300/300',
          trackCount: 24,
          source: 'local',
          isLocal: true,
        ),
        const Playlist(
          id: 'pl_workout',
          title: 'Workout Beats',
          description: 'High energy tracks for your workout session.',
          thumbnail: 'https://picsum.photos/seed/pl2/300/300',
          trackCount: 18,
          source: 'local',
          isLocal: true,
        ),
        const Playlist(
          id: 'pl_chill',
          title: 'Chill Vibes',
          description: 'Relax and unwind with these chill tracks.',
          thumbnail: 'https://picsum.photos/seed/pl3/300/300',
          trackCount: 32,
          source: 'local',
          isLocal: true,
        ),
        const Playlist(
          id: 'pl_focus',
          title: 'Deep Focus',
          description: 'Stay in the zone with focus-enhancing music.',
          thumbnail: 'https://picsum.photos/seed/pl4/300/300',
          trackCount: 15,
          source: 'local',
          isLocal: true,
        ),
      ];

  void create(String title, String description) {
    final pl = Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      thumbnail: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/300/300',
      source: 'local',
      isLocal: true,
    );
    state = [...state, pl];
  }

  void delete(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

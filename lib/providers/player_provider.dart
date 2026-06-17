import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_models.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});

final miniPlayerProvider = Provider<MiniPlayerData?>((ref) {
  final state = ref.watch(playerProvider);
  if (state.currentTrack == null) return null;
  return MiniPlayerData(
    title: state.currentTrack!.title,
    artist: state.currentTrack!.artist,
    thumbnail: state.currentTrack!.thumbnail,
    isPlaying: state.isPlaying,
  );
});

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(const PlayerState());

  void play(Track track, {List<Track>? queue, int? index}) {
    final q = queue ?? [track];
    final idx = index ?? 0;
    state = state.copyWith(
      currentTrack: track,
      isPlaying: true,
      queue: q,
      queueIndex: idx,
      position: Duration.zero,
      duration: Duration(seconds: track.duration),
    );
    _startProgressSimulation();
  }

  void playQueue(List<Track> queue, int index) {
    if (queue.isEmpty) return;
    play(queue[index], queue: queue, index: index);
  }

  void togglePlay() {
    if (state.currentTrack == null) return;
    state = state.copyWith(isPlaying: !state.isPlaying);
    if (state.isPlaying) _startProgressSimulation();
  }

  void pause() => state = state.copyWith(isPlaying: false);

  void next() {
    if (state.queue.isEmpty) return;
    int nextIdx;
    if (state.isShuffle) {
      nextIdx = (state.queueIndex + 1 + (state.queue.length - 1)) % state.queue.length;
    } else {
      nextIdx = (state.queueIndex + 1) % state.queue.length;
    }
    play(state.queue[nextIdx], queue: state.queue, index: nextIdx);
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final prevIdx = (state.queueIndex - 1 + state.queue.length) % state.queue.length;
    play(state.queue[prevIdx], queue: state.queue, index: prevIdx);
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
  }

  void toggleShuffle() => state = state.copyWith(isShuffle: !state.isShuffle);

  void toggleRepeat() {
    final next = RepeatMode.values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: next);
  }

  void setVolume(double volume) => state = state.copyWith(volume: volume.clamp(0.0, 1.0));

  void addToQueue(Track track) {
    final newQueue = [...state.queue, track];
    state = state.copyWith(queue: newQueue);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= state.queue.length) return;
    final newQueue = [...state.queue]..removeAt(index);
    final newIndex = index < state.queueIndex
        ? state.queueIndex - 1
        : state.queueIndex.clamp(0, newQueue.length - 1);
    state = state.copyWith(queue: newQueue, queueIndex: newIndex);
  }

  void _startProgressSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (!state.isPlaying) return false;
      if (state.currentTrack == null) return false;
      final newPos = state.position + const Duration(seconds: 1);
      if (newPos >= state.duration) {
        if (state.repeatMode == RepeatMode.one) {
          seek(Duration.zero);
        } else {
          next();
        }
        return false;
      }
      state = state.copyWith(position: newPos);
      return true;
    });
  }
}

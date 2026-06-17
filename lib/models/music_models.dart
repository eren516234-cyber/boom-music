class Track {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String thumbnail;
  final int duration; // seconds
  final String source; // 'youtube', 'jiosaavn', 'deezer', 'audius'
  final String? streamUrl;
  bool isLiked;
  bool isDownloaded;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId = '',
    this.album = '',
    this.albumId = '',
    required this.thumbnail,
    required this.duration,
    required this.source,
    this.streamUrl,
    this.isLiked = false,
    this.isDownloaded = false,
  });

  String get durationString {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'album': album,
        'albumId': albumId,
        'thumbnail': thumbnail,
        'duration': duration,
        'source': source,
        'streamUrl': streamUrl,
        'isLiked': isLiked,
        'isDownloaded': isDownloaded,
      };

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        artist: j['artist'] ?? '',
        artistId: j['artistId'] ?? '',
        album: j['album'] ?? '',
        albumId: j['albumId'] ?? '',
        thumbnail: j['thumbnail'] ?? '',
        duration: j['duration'] ?? 0,
        source: j['source'] ?? 'youtube',
        streamUrl: j['streamUrl'],
        isLiked: j['isLiked'] ?? false,
        isDownloaded: j['isDownloaded'] ?? false,
      );
}

class Album {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String thumbnail;
  final int? year;
  final int? trackCount;
  final String source;
  final List<Track> tracks;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId = '',
    required this.thumbnail,
    this.year,
    this.trackCount,
    required this.source,
    this.tracks = const [],
  });
}

class Artist {
  final String id;
  final String name;
  final String thumbnail;
  final String? banner;
  final String? bio;
  final int? followers;
  final String source;

  const Artist({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.banner,
    this.bio,
    this.followers,
    required this.source,
  });
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final int trackCount;
  final String source;
  final List<Track> tracks;
  final bool isLocal;

  const Playlist({
    required this.id,
    required this.title,
    this.description = '',
    required this.thumbnail,
    this.trackCount = 0,
    required this.source,
    this.tracks = const [],
    this.isLocal = false,
  });
}

class SearchResults {
  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;

  const SearchResults({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
  });
}

class PlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final double volume;
  final List<Track> queue;
  final int queueIndex;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.none,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.queue = const [],
    this.queueIndex = 0,
  });

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    bool? isShuffle,
    RepeatMode? repeatMode,
    Duration? position,
    Duration? duration,
    double? volume,
    List<Track>? queue,
    int? queueIndex,
  }) =>
      PlayerState(
        currentTrack: currentTrack ?? this.currentTrack,
        isPlaying: isPlaying ?? this.isPlaying,
        isShuffle: isShuffle ?? this.isShuffle,
        repeatMode: repeatMode ?? this.repeatMode,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        volume: volume ?? this.volume,
        queue: queue ?? this.queue,
        queueIndex: queueIndex ?? this.queueIndex,
      );
}

enum RepeatMode { none, one, all }

class LogEntry {
  final DateTime time;
  final String level;
  final String scope;
  final String message;

  const LogEntry({
    required this.time,
    required this.level,
    required this.scope,
    required this.message,
  });
}

class Plugin {
  final String id;
  final String name;
  final String author;
  final String description;
  final String version;
  bool isEnabled;
  final bool isInstalled;

  Plugin({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.version,
    this.isEnabled = false,
    this.isInstalled = false,
  });
}

class MiniPlayerData {
  final String title;
  final String artist;
  final String thumbnail;
  final bool isPlaying;

  const MiniPlayerData({
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.isPlaying,
  });
}

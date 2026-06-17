# 🎵 Boom Music

A beautiful, feature-rich music player app for Android — built with Flutter.

## Features

- 🌐 **Multi-source**: YouTube Music, JioSaavn, Deezer, Audius
- 🎨 **Beautiful UI** — pink-themed with dark mode & custom accent colors
- 📱 **20+ screens** with full navigation
- 🎛️ **Parametric EQ** with presets (Bass Boost, Rock, Classical, etc.)
- ❤️ **Like songs** & build local playlists
- 🔊 **Background playback** with media controls
- 🔍 **Universal search** across all sources
- 🎤 **Lyrics screen** (KuGou, LrcLib integration)
- ⚙️ **Plugin system** for extensibility
- 📥 **Downloads** for offline listening
- 🎵 **Local file** scanner

## Screens

| Screen | Description |
|--------|-------------|
| Dashboard | Top tracks, albums, new releases, queue panel |
| Search | Tracks / Albums / Artists tabs |
| Library | Playlists, Albums, Artists |
| Now Playing | Full-screen player with artwork |
| Lyrics | Synced lyrics viewer |
| Queue | Reorderable playback queue |
| Playlist Detail | Filterable track list with context menu |
| Album Detail | Full album with play/shuffle |
| Artist Detail | Top tracks + discography |
| Liked Songs | Saved favorites |
| History | Recently played |
| Downloads | Offline tracks |
| Local Files | On-device music scanner |
| EQ | 10-band parametric equalizer |
| Settings → General | Source, playback, storage settings |
| Settings → Key Shortcuts | Keyboard shortcuts reference |
| Settings → Plugins | Installed & store |
| Settings → Themes | Accent color & dark mode |
| Settings → Logs | Live log viewer with filters |
| Settings → What's New | Changelog |

## Build

```bash
flutter pub get
flutter build apk --release
```

APK is built automatically via GitHub Actions on every push to `main`.
Download the latest APK from [Actions → Artifacts](../../actions).

## Tech Stack

- Flutter 3.22+ / Dart 3.3+
- `flutter_riverpod` — state management
- `go_router` — navigation
- `dio` — HTTP / API calls
- `just_audio` + `audio_service` — playback
- `cached_network_image` — image caching
- `hive` — local storage

## APIs

| Source | Endpoint |
|--------|----------|
| YouTube Music | InnerTube (`music.youtube.com/youtubei/v1`) |
| Deezer | `api.deezer.com` (no auth) |
| Audius | `discoveryprovider.audius.co/v1` |
| JioSaavn | `jiosaavn.com/api.php` |

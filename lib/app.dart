import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/player/now_playing_screen.dart';
import 'screens/player/lyrics_screen.dart';
import 'screens/player/queue_screen.dart';
import 'screens/playlist/playlist_detail_screen.dart';
import 'screens/album/album_detail_screen.dart';
import 'screens/artist/artist_detail_screen.dart';
import 'screens/liked/liked_songs_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/downloads/downloads_screen.dart';
import 'screens/local/local_files_screen.dart';
import 'screens/eq/eq_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'providers/theme_provider.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
        GoRoute(path: '/library', builder: (c, s) => const LibraryScreen()),
        GoRoute(path: '/liked', builder: (c, s) => const LikedSongsScreen()),
        GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
        GoRoute(path: '/downloads', builder: (c, s) => const DownloadsScreen()),
        GoRoute(path: '/local', builder: (c, s) => const LocalFilesScreen()),
        GoRoute(path: '/eq', builder: (c, s) => const EQScreen()),
        GoRoute(
          path: '/playlist/:id',
          builder: (c, s) => PlaylistDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/album/:id',
          builder: (c, s) => AlbumDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/artist/:id',
          builder: (c, s) => ArtistDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/now-playing',
      builder: (c, s) => const NowPlayingScreen(),
    ),
    GoRoute(
      path: '/lyrics',
      builder: (c, s) => const LyricsScreen(),
    ),
    GoRoute(
      path: '/queue',
      builder: (c, s) => const QueueScreen(),
    ),
  ],
);

class BoomMusicApp extends ConsumerWidget {
  const BoomMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

    return MaterialApp.router(
      title: 'Boom Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    ('/', Icons.home_rounded, 'Home'),
    ('/search', Icons.search_rounded, 'Search'),
    ('/library', Icons.library_music_rounded, 'Library'),
    ('/liked', Icons.favorite_rounded, 'Liked'),
    ('/history', Icons.history_rounded, 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: widget.child),
          const MiniPlayerBar(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          context.go(_navItems[i].$1);
        },
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.$2),
                  label: item.$3,
                ))
            .toList(),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        height: 65,
      ),
    );
  }
}

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(miniPlayerProvider);
    if (player == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/now-playing'),
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                player.thumbnail,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    player.artist,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
              onPressed: () => ref.read(playerProvider.notifier).previous(),
            ),
            IconButton(
              icon: Icon(
                player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
              onPressed: () => ref.read(playerProvider.notifier).next(),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

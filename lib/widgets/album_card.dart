import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_models.dart';
import '../providers/player_provider.dart';

class AlbumCard extends ConsumerWidget {
  final Album album;
  final VoidCallback? onTap;
  final double width;

  const AlbumCard({super.key, required this.album, this.onTap, this.width = 160});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: album.thumbnail,
                    width: width,
                    height: width,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: width,
                      height: width,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.album_rounded, size: 40),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onTap,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artist,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final double width;

  const ArtistCard({super.key, required this.artist, this.onTap, this.width = 120});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: artist.thumbnail,
                width: width,
                height: width,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: width,
                  height: width,
                  color: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.person_rounded, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final double width;

  const PlaylistCard({super.key, required this.playlist, this.onTap, this.width = 160});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: playlist.thumbnail,
                width: width,
                height: width,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: width,
                  height: width,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.queue_music_rounded, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${playlist.trackCount} tracks',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

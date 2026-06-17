import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Widget? filterWidget;

  const SectionHeader({
    super.key,
    required this.title,
    this.badge,
    this.onPrevious,
    this.onNext,
    this.filterWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (filterWidget != null) filterWidget!,
          if (onPrevious != null || onNext != null) ...[
            const SizedBox(width: 8),
            _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
            const SizedBox(width: 4),
            _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
    );
  }
}

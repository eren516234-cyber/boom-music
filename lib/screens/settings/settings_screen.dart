import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/music_models.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _SettingsPage _page = _SettingsPage.general;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    final sidebar = Container(
      width: isWide ? 220 : double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: isWide ? Border(right: BorderSide(color: theme.colorScheme.primary.withOpacity(0.15))) : null,
      ),
      child: Column(
        children: [
          if (!isWide)
            AppBar(title: const Text('Settings'), leading: const BackButton()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(Icons.settings_outlined, 'General', _SettingsPage.general, _page, (p) => setState(() => _page = p), isWide),
                _SidebarItem(Icons.keyboard_outlined, 'Key Shortcuts', _SettingsPage.shortcuts, _page, (p) => setState(() => _page = p), isWide),
                _SidebarItem(Icons.extension_outlined, 'Plugins', _SettingsPage.plugins, _page, (p) => setState(() => _page = p), isWide),
                _SidebarItem(Icons.palette_outlined, 'Themes', _SettingsPage.themes, _page, (p) => setState(() => _page = p), isWide),
                _SidebarItem(Icons.article_outlined, 'Logs', _SettingsPage.logs, _page, (p) => setState(() => _page = p), isWide),
                _SidebarItem(Icons.new_releases_outlined, "What's New", _SettingsPage.whatsNew, _page, (p) => setState(() => _page = p), isWide),
                const Divider(indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('v1.0.0 (1)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!isWide) {
      if (_page == _SettingsPage.general) return sidebar;
      return Scaffold(
        appBar: AppBar(
          title: Text(_page.label),
          leading: BackButton(onPressed: () => setState(() => _page = _SettingsPage.general)),
        ),
        body: _pageContent(context, ref),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Row(
        children: [
          sidebar,
          Expanded(child: _pageContent(context, ref)),
        ],
      ),
    );
  }

  Widget _pageContent(BuildContext context, WidgetRef ref) {
    return switch (_page) {
      _SettingsPage.general => _GeneralSettings(),
      _SettingsPage.shortcuts => _ShortcutsSettings(),
      _SettingsPage.plugins => _PluginsSettings(),
      _SettingsPage.themes => _ThemesSettings(),
      _SettingsPage.logs => _LogsSettings(),
      _SettingsPage.whatsNew => _WhatsNewSettings(),
    };
  }
}

enum _SettingsPage {
  general('General'),
  shortcuts('Key Shortcuts'),
  plugins('Plugins'),
  themes('Themes'),
  logs('Logs'),
  whatsNew("What's New");

  final String label;
  const _SettingsPage(this.label);
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final _SettingsPage page;
  final _SettingsPage current;
  final void Function(_SettingsPage) onTap;
  final bool isWide;

  const _SidebarItem(this.icon, this.label, this.page, this.current, this.onTap, this.isWide);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = page == current;
    return ListTile(
      leading: Icon(icon, color: selected ? theme.colorScheme.primary : null, size: 22),
      title: Text(label, style: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        color: selected ? theme.colorScheme.primary : null,
      )),
      selected: selected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      horizontalTitleGap: 8,
      onTap: () => onTap(page),
    );
  }
}

// ── General ──────────────────────────────────────────────────────────────────
class _GeneralSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(apiSourceProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle('General'),
        _SettingsTile(
          title: 'Music Source',
          subtitle: 'Primary API for discovering music',
          trailing: DropdownButton<String>(
            value: source,
            underline: const SizedBox(),
            items: ApiSourceNotifier.sources
                .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                .toList(),
            onChanged: (v) => v != null ? ref.read(apiSourceProvider.notifier).setSource(v) : null,
          ),
        ),
        _SettingsTile(title: 'Crossfade', subtitle: 'Smooth transition between tracks',
            trailing: Switch(value: false, onChanged: (_) {})),
        _SettingsTile(title: 'Gapless playback', subtitle: 'No pause between tracks',
            trailing: Switch(value: true, onChanged: (_) {})),
        _SettingsTile(title: 'High quality streaming', subtitle: 'Use higher bitrate when available',
            trailing: Switch(value: true, onChanged: (_) {})),
        _SettingsTile(title: 'Auto-play recommendations', subtitle: 'Continue playing similar songs',
            trailing: Switch(value: false, onChanged: (_) {})),
        const _SectionTitle('Storage'),
        _SettingsTile(title: 'Cache size', subtitle: 'Max storage for buffered audio',
            trailing: Text('500 MB', style: TextStyle(color: Colors.grey[600]))),
        _SettingsTile(title: 'Download location', subtitle: '/storage/music/BoomMusic',
            trailing: const Icon(Icons.chevron_right_rounded)),
        const _SectionTitle('About'),
        _SettingsTile(title: 'Version', subtitle: '1.0.0 (build 1)',
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600]))),
        _SettingsTile(title: 'Open source licenses',
            trailing: const Icon(Icons.chevron_right_rounded), onTap: () {}),
      ],
    );
  }
}

// ── Shortcuts ────────────────────────────────────────────────────────────────
class _ShortcutsSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      ('Play / Pause', 'Space'),
      ('Next track', '→'),
      ('Previous track', '←'),
      ('Volume up', '↑'),
      ('Volume down', '↓'),
      ('Toggle shuffle', 'S'),
      ('Toggle repeat', 'R'),
      ('Like song', 'L'),
      ('Open search', '/'),
      ('Open queue', 'Q'),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle('Keyboard Shortcuts'),
        ...shortcuts.map((s) => _SettingsTile(
              title: s.$1,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(s.$2, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
              ),
            )),
      ],
    );
  }
}

// ── Plugins ───────────────────────────────────────────────────────────────────
class _PluginsSettings extends StatefulWidget {
  @override
  State<_PluginsSettings> createState() => _PluginsSettingsState();
}

class _PluginsSettingsState extends State<_PluginsSettings> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _plugins = [
    Plugin(id: 'nebula', name: 'Nebula Streaming', author: 'astraldev', description: 'Stream music from the Nebula network with adaptive bitrate and gapless playback.', version: 'v2.1.0', isEnabled: true, isInstalled: true),
    Plugin(id: 'crystal', name: 'Crystal Metadata', author: 'prismatics', description: 'Fetch rich metadata including album art, credits, and liner notes from the Crystal database.', version: 'v1.4.2', isEnabled: true, isInstalled: true),
    Plugin(id: 'moonbeam', name: 'Moonbeam Lyrics', author: 'lunarsoft', description: 'Synced lyrics with karaoke mode and multi-language translation support.', version: 'v3.0.1', isEnabled: true, isInstalled: true),
    Plugin(id: 'drift', name: 'Drift Scrobbler', author: 'wavecollective', description: 'Scrobble your listening history to Drift.fm with offline queue and smart deduplication.', version: 'v1.0.7', isEnabled: false, isInstalled: true),
    Plugin(id: 'aurora', name: 'Aurora Discovery', author: 'northlightlabs', description: 'AI-powered music recommendations based on your listening patterns and mood.', version: 'v0.9.3', isEnabled: true, isInstalled: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              const Text('Plugins', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Plugin'),
                onPressed: () {},
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [Tab(text: 'Installed'), Tab(text: 'Store')],
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _plugins.length,
                itemBuilder: (_, i) => _PluginTile(
                  plugin: _plugins[i],
                  onToggle: () => setState(() => _plugins[i].isEnabled = !_plugins[i].isEnabled),
                ),
              ),
              const Center(child: Text('Plugin store coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}

class _PluginTile extends StatelessWidget {
  final Plugin plugin;
  final VoidCallback onToggle;
  const _PluginTile({required this.plugin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plugin.name, style: TextStyle(fontWeight: FontWeight.w700, color: plugin.isEnabled ? null : Colors.grey)),
                      const SizedBox(width: 6),
                      Text('by ${plugin.author}', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(plugin.description, style: TextStyle(fontSize: 12, color: plugin.isEnabled ? Colors.grey[600] : Colors.grey[400])),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                    child: Text(plugin.version, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(value: plugin.isEnabled, onChanged: (_) => onToggle()),
                IconButton(icon: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey[400]), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey[400]), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Themes ────────────────────────────────────────────────────────────────────
class _ThemesSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle('Appearance'),
        _SettingsTile(
          title: 'Dark mode',
          trailing: Switch(
            value: mode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Accent Color'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AccentColorNotifier.presets.map((color) {
            final isSelected = accent.value == color.value;
            return GestureDetector(
              onTap: () => ref.read(accentColorProvider.notifier).setColor(color),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12)]
                      : null,
                ),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Logs ──────────────────────────────────────────────────────────────────────
class _LogsSettings extends StatefulWidget {
  @override
  State<_LogsSettings> createState() => _LogsSettingsState();
}

class _LogsSettingsState extends State<_LogsSettings> {
  String _search = '';
  String? _levelFilter;
  String? _scopeFilter;

  final _logs = [
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 5)), level: 'DEBUG', scope: 'plugins', message: 'Plugin compiled successfully (113835 chars)'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 5)), level: 'DEBUG', scope: 'plugins', message: 'Evaluating plugin code'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 4)), level: 'INFO', scope: 'plugins', message: 'Plugin nuclear-plugin-fake-data@0.1.0 loaded successfully'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 4)), level: 'DEBUG', scope: 'plugins', message: 'Enabling plugin nuclear-plugin-fake-data'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 3)), level: 'INFO', scope: 'playback', message: 'Set source: http://127.0.0.1:9100/stream/...'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 2)), level: 'DEBUG', scope: 'http', message: 'GET https://cdn.example.net/registry@maste'),
    LogEntry(time: DateTime.now().subtract(const Duration(seconds: 1)), level: 'WARN', scope: 'streaming', message: 'Buffer underrun detected, rebuffering...'),
    LogEntry(time: DateTime.now(), level: 'ERROR', scope: 'queue', message: 'Failed to resolve stream URL for track id=abc123'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _logs.where((l) {
      final matchesSearch = _search.isEmpty || l.message.toLowerCase().contains(_search.toLowerCase());
      final matchesLevel = _levelFilter == null || l.level.toLowerCase() == _levelFilter;
      final matchesScope = _scopeFilter == null || l.scope == _scopeFilter;
      return matchesSearch && matchesLevel && matchesScope;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text('Logs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              OutlinedButton.icon(icon: const Icon(Icons.delete_outline_rounded, size: 16), label: const Text('Clear'), onPressed: () {}),
              const SizedBox(width: 8),
              OutlinedButton.icon(icon: const Icon(Icons.upload_outlined, size: 16), label: const Text('Export'), onPressed: () {}),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search logs…', prefixIcon: Icon(Icons.search_rounded), isDense: true),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
            spacing: 6,
            children: [
              const Text('Level:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ..._buildChips(['error', 'warn', 'info', 'debug', 'trace'], _levelFilter, (v) => setState(() => _levelFilter = v)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
            spacing: 6,
            children: [
              const Text('Scope:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ..._buildChips(['queue', 'plugins', 'playback', 'http', 'streaming'], _scopeFilter, (v) => setState(() => _scopeFilter = v)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${filtered.length} entries', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final log = filtered[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.time.hour.toString().padLeft(2,'0')}:${log.time.minute.toString().padLeft(2,'0')}:${log.time.second.toString().padLeft(2,'0')}.${log.time.millisecond.toString().padLeft(3,'0')}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      _LevelBadge(level: log.level),
                      const SizedBox(width: 6),
                      _ScopeBadge(scope: log.scope),
                      const SizedBox(width: 8),
                      Expanded(child: Text(log.message, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildChips(List<String> items, String? selected, void Function(String?) onSelect) {
    return items.map((item) => FilterChip(
      label: Text(item, style: const TextStyle(fontSize: 11)),
      selected: selected == item,
      onSelected: (_) => onSelect(selected == item ? null : item),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    )).toList();
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level.toUpperCase()) {
      'ERROR' => const Color(0xFFE53935),
      'WARN' => const Color(0xFFFB8C00),
      'INFO' => const Color(0xFF43A047),
      'DEBUG' => const Color(0xFF7B2FBE),
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(level.toUpperCase(), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _ScopeBadge extends StatelessWidget {
  final String scope;
  const _ScopeBadge({required this.scope});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(scope, style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.w700)),
    );
  }
}

// ── What's New ────────────────────────────────────────────────────────────────
class _WhatsNewSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("What's New", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        _ChangelogItem(
          version: '1.0.0',
          date: 'June 2025',
          changes: [
            '🎵 Initial release of Boom Music',
            '🌐 Multi-source support: YouTube Music, JioSaavn, Deezer, Audius',
            '🎨 Beautiful pink-themed UI with dark mode',
            '📱 20+ screens with full navigation',
            '🎛️ Parametric EQ with presets',
            '❤️ Like songs & build playlists',
            '🔊 Background playback support',
            '🔍 Universal search across all sources',
            '🎤 Lyrics screen with sync support',
            '⚙️ Plugin system for extensibility',
          ],
        ),
      ],
    );
  }
}

class _ChangelogItem extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;
  const _ChangelogItem({required this.version, required this.date, required this.changes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('v$version', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Text(date, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            ...changes.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(c, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(title, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      )),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

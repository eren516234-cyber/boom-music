import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _eqProvider = StateNotifierProvider<EQNotifier, EQState>((ref) => EQNotifier());

class EQState {
  final bool enabled;
  final List<double> bands; // 60, 170, 310, 600, 1k, 3k, 6k, 12k, 14k, 16k Hz
  final double bass;
  final double treble;
  final String preset;

  const EQState({
    this.enabled = true,
    this.bands = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.bass = 0,
    this.treble = 0,
    this.preset = 'Flat',
  });

  EQState copyWith({bool? enabled, List<double>? bands, double? bass, double? treble, String? preset}) =>
      EQState(
        enabled: enabled ?? this.enabled,
        bands: bands ?? this.bands,
        bass: bass ?? this.bass,
        treble: treble ?? this.treble,
        preset: preset ?? this.preset,
      );
}

class EQNotifier extends StateNotifier<EQState> {
  EQNotifier() : super(const EQState());

  void toggle() => state = state.copyWith(enabled: !state.enabled);

  void setBand(int index, double value) {
    final newBands = [...state.bands];
    newBands[index] = value;
    state = state.copyWith(bands: newBands, preset: 'Custom');
  }

  void setBass(double v) => state = state.copyWith(bass: v);
  void setTreble(double v) => state = state.copyWith(treble: v);

  void applyPreset(String name) {
    final presets = {
      'Flat': List.filled(10, 0.0),
      'Bass Boost': [6.0, 5.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      'Treble Boost': [0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 4.0, 5.0, 6.0, 6.0],
      'Vocal': [0.0, 0.0, 2.0, 4.0, 4.0, 3.0, 2.0, 0.0, 0.0, 0.0],
      'Rock': [5.0, 3.0, 2.0, 0.0, -1.0, 0.0, 2.0, 4.0, 5.0, 5.0],
      'Electronic': [4.0, 3.0, 0.0, -2.0, 0.0, 2.0, 0.0, 2.0, 4.0, 4.0],
      'Classical': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -2.0, -3.0, -3.0, -3.0],
    };
    state = state.copyWith(bands: presets[name] ?? List.filled(10, 0.0), preset: name);
  }
}

class EQScreen extends ConsumerWidget {
  const EQScreen({super.key});

  static const _freqs = ['60', '170', '310', '600', '1K', '3K', '6K', '12K', '14K', '16K'];
  static const _presets = ['Flat', 'Bass Boost', 'Treble Boost', 'Vocal', 'Rock', 'Electronic', 'Classical'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eq = ref.watch(_eqProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        actions: [
          Switch(
            value: eq.enabled,
            onChanged: (_) => ref.read(_eqProvider.notifier).toggle(),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Presets
            const Text('Presets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets
                  .map((p) => FilterChip(
                        label: Text(p),
                        selected: eq.preset == p,
                        onSelected: (_) => ref.read(_eqProvider.notifier).applyPreset(p),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // EQ Bands
            const Text('Bands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              height: 240,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(10, (i) {
                  return Expanded(
                    child: _BandSlider(
                      freq: _freqs[i],
                      value: eq.bands[i],
                      enabled: eq.enabled,
                      onChanged: (v) => ref.read(_eqProvider.notifier).setBand(i, v),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Bass / Treble
            const Text('Bass & Treble', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _LabeledSlider(
              label: 'Bass',
              icon: Icons.graphic_eq_rounded,
              value: eq.bass,
              enabled: eq.enabled,
              onChanged: ref.read(_eqProvider.notifier).setBass,
            ),
            _LabeledSlider(
              label: 'Treble',
              icon: Icons.high_quality_rounded,
              value: eq.treble,
              enabled: eq.enabled,
              onChanged: ref.read(_eqProvider.notifier).setTreble,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final String freq;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _BandSlider({required this.freq, required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: value,
              min: -12,
              max: 12,
              onChanged: enabled ? onChanged : null,
              activeColor: enabled ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
        ),
        Text(
          value >= 0 ? '+${value.toStringAsFixed(0)}' : value.toStringAsFixed(0),
          style: TextStyle(fontSize: 9, color: enabled ? theme.colorScheme.primary : Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(freq, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _LabeledSlider({
    required this.label, required this.icon, required this.value,
    required this.enabled, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(
          child: Slider(
            value: value,
            min: -12,
            max: 12,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value >= 0 ? '+${value.toStringAsFixed(0)}' : value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

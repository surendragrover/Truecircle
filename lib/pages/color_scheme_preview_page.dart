import 'package:flutter/material.dart';
import '../theme/coral_theme.dart';

class ColorSchemePreviewPage extends StatelessWidget {
  const ColorSchemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = <_SwatchInfo>[
      _SwatchInfo(label: 'Coral Light', color: const Color(0xFFFFA385), desc: 'Top gradient / soft background'),
      _SwatchInfo(label: 'Coral Base', color: const Color(0xFFFF7F50), desc: 'Primary brand coral'),
      _SwatchInfo(label: 'Coral Deep', color: const Color(0xFFFF6233), desc: 'Accents / buttons / emphasis'),
      _SwatchInfo(label: 'Coral Dark', color: CoralTheme.dark, desc: 'Dark contrast surfaces'),
      _SwatchInfo(label: 'Accent Orange', color: Colors.orange, desc: 'Highlights / call-to-action'),
      _SwatchInfo(label: 'Success Green', color: Colors.green, desc: 'Positive state feedback'),
      _SwatchInfo(label: 'Info Blue', color: Colors.lightBlueAccent, desc: 'Informational elements'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Scheme Preview'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: CoralTheme.appBarGradient),
        ),
      ),
      body: Container(
        decoration: CoralTheme.background,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'TrueCircle Coral Visual System',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Core palette blocks with usage guidance. Keep contrast for accessibility (WCAG AA).',
              style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
            ),
            const SizedBox(height: 16),
            ...colors.map((c) => _SwatchTile(info: c)),
            const SizedBox(height: 24),
            _GradientPreview(),
            const SizedBox(height: 24),
            const _UsageGuidelines(),
          ],
        ),
      ),
    );
  }
}

class _SwatchInfo {
  final String label;
  final Color color;
  final String desc;
  _SwatchInfo({required this.label, required this.color, required this.desc});
}

class _SwatchTile extends StatelessWidget {
  final _SwatchInfo info;
  const _SwatchTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              color: info.color.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(info.desc, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFA385),
              Color(0xFFFF7F50),
              Color(0xFFFF6233),
            ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: const Center(
        child: Text(
          'Primary Coral Gradient',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class _UsageGuidelines extends StatelessWidget {
  const _UsageGuidelines();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Usage Guidelines', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('• Light coral for backgrounds / soft cards', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('• Base coral for large areas (scaffolds / major headers)', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('• Deep coral for buttons, CTAs, emphasis chips', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('• Dark theme swatches for contrast surfaces', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('• Accent orange sparingly for call-to-action highlights', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('• Maintain minimum contrast ratio 4.5:1 for body text', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

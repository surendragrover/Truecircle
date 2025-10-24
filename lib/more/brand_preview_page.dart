import 'package:flutter/material.dart';

/// Quick in‑app visual check for logo, avatar and theme colors.
class BrandPreviewPage extends StatelessWidget {
  const BrandPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Brand Preview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Verify logo, avatar, and a few themed components below (offline assets).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Logo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Logo'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/truecircle_logo.png',
                        height: 64,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'assets/images/truecircle_logo.png',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Avatar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avatar'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: const AssetImage(
                          'assets/images/avatar.png',
                        ),
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'assets/images/avatar.png',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Theme swatches and components
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme snapshot'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _swatch('primary', scheme.primary, scheme.onPrimary),
                      _swatch(
                        'primaryContainer',
                        scheme.primaryContainer,
                        scheme.onPrimaryContainer,
                      ),
                      _swatch('surface', scheme.surface, scheme.onSurface),
                      _swatch(
                        'surfaceContainerLow',
                        scheme.surfaceContainerLow,
                        scheme.onSurface,
                      ),
                      _swatch(
                        'outlineVariant',
                        scheme.outlineVariant,
                        scheme.onSurface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Elevated Button'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Outlined Button'),
                      ),
                      const SizedBox(width: 8),
                      Chip(label: const Text('Chip')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swatch(String label, Color bg, Color fg) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

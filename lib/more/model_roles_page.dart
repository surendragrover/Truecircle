import 'package:flutter/material.dart';

/// Explains each offline AI role with inputs, outputs, and safety rules.
class ModelRolesPage extends StatelessWidget {
  const ModelRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    Widget section(String title, List<String> points) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            const SizedBox(height: 8),
            ...points.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: cs.outline)),
                    Expanded(child: Text(p)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Model Roles')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'TrueCircle runs fully offline mode. Below are clear, on-device roles and boundaries.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Add-ons like a personalization summary can be placed here if needed.

            // Dr. Iris
            section('Dr. Iris (emotional support)', [
              'Inputs: Your typed message (and optional mood info in text).',
              'Outputs: 2–3 calm, compassionate lines with one tiny, safe next step (no medical claims).',
              'Safety: If risk words appear (e.g., self‑harm), shows immediate help guidance.',
              'Personalization: Tone (warm/neutral) and breathing style (4‑4‑6/box/equal) applied on-device.',
              'Privacy: No network, no external API calls.',
            ]),

            // Relationship Coach
            section('Relationship Coach', [
              'Inputs: A short summary of your recent chat/notes (if provided).',
              'Outputs: One clear reflective sentence suggestion (kind, specific).',
              'Privacy: Processes only on device; nothing is uploaded.',
            ]),

            // Festival Companion
            section('Festival Companion', [
              'Inputs: Contact name (optional) and relation type.',
              'Outputs: A short, warm greeting message with inclusive wording.',
              'Privacy: Fully offline; no contact permissions requested.',
            ]),

            // Sentiment/Stress Analyzer
            section('Sentiment & Stress Heuristic', [
              'Inputs: Your text entry (e.g., mentions of mood or stress).',
              'Outputs: Low/Medium/High indicator based on simple keywords and optional numeric hints.',
              'Note: Educational only; not a diagnosis.',
            ]),

            // Learning boundaries
            section('On‑device learning (defined & minimal)', [
              'What is saved: A tiny preference profile (tone, language, breath style) and a small count of common words (e.g., anxious, sad).',
              'What is NOT saved: No sensitive history is uploaded; there are no network calls.',
              'Control: Preferences can be adjusted in‑app; feedback may fine‑tune tone/micro‑steps locally.',
            ]),

            // Guardrails
            section('Guardrails', [
              'Privacy‑first offline mode — no contacts, calls, SMS, or online services.',
              'Educational guidance only; seek local professional support as needed.',
              'Short, clear language; encourage small, safe actions.',
            ]),
          ],
        ),
      ),
    );
  }
}

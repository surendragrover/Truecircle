import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/app_data_preloader.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  List<Map<String, dynamic>> _getFaqList() {
    final dynamic data = AppDataPreloader.instance.getData('faq');
    if (data is Map<String, dynamic> && data['faqs'] is List) {
      return (data['faqs'] as List).cast<Map<String, dynamic>>();
    } else if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _getFaqList();

    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'FAQ'),
      body: faqs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No FAQs available offline right now. Please try again later.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = faqs[index];
                final q = (item['question'] ?? '').toString();
                final a = (item['answer'] ?? '').toString();
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: const Icon(Icons.help_outline),
                    title: Text(
                      q.isEmpty ? 'Question' : q,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [Text(a.isEmpty ? 'No answer provided.' : a)],
                  ),
                );
              },
            ),
    );
  }
}

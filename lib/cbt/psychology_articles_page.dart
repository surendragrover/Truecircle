import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';

class PsychologyArticlesPage extends StatelessWidget {
  const PsychologyArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Psychology Articles'),
      body: FutureBuilder<List<Map<String, String>>>(
        future: JsonDataService.instance.getPsychologyArticles(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final a = items[i];
              return ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(a['title'] ?? ''),
                subtitle: Text(
                  a['summary']?.toString().trim().isEmpty == true
                      ? ''
                      : (a['summary'] ?? ''),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _ArticleDetail(article: a)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArticleDetail extends StatelessWidget {
  final Map<String, String> article;
  const _ArticleDetail({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article['title'] ?? 'Article')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if ((article['summary'] ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                article['summary']!,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          Text(article['body'] ?? ''),
        ],
      ),
    );
  }
}

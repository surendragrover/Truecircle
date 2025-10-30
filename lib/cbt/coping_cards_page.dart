import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';
class CopingCardsPage extends StatefulWidget {
  const CopingCardsPage({super.key});

  @override
  State<CopingCardsPage> createState() => _CopingCardsPageState();
}

class _CopingCardsPageState extends State<CopingCardsPage> {
  late Future<List<String>> _assetCardsFuture;
  List<String> _customCards = [];

  @override
  void initState() {
    super.initState();
    _assetCardsFuture = JsonDataService.instance.getCopingCards();
    _loadCustom();
  }

  Future<void> _loadCustom() async {
    try {
      final box = await Hive.openBox('coping_cards');
      final list = (box.get('custom', defaultValue: <String>[]) as List)
          .map((e) => e.toString())
          .toList();
      setState(() => _customCards = list);
    } catch (_) {
      // ignore silently
    }
  }

  Future<void> _saveCustom() async {
    try {
      final box = await Hive.openBox('coping_cards');
      await box.put('custom', _customCards);
    } catch (_) {}
  }

  Future<void> _addCardDialog() async {
    final controller = TextEditingController();
    final added = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Coping Card'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write a short, helpful reminder for tough moments…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(context, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (added != null && added.trim().isNotEmpty) {
      setState(() => _customCards.insert(0, added.trim()));
      await _saveCustom();
    }
  }

  Future<void> _removeCustomAt(int index) async {
    setState(() => _customCards.removeAt(index));
    await _saveCustom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Coping Cards'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: FutureBuilder<List<String>>(
        future: _assetCardsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final assetCards = snap.data ?? const [];
          final all = [..._customCards, ...assetCards];

          if (all.isEmpty) {
            return const Center(child: Text('No coping cards found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: all.length,
            itemBuilder: (context, i) {
              final text = all[i];
              final isCustom = i < _customCards.length;
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onLongPress: isCustom
                      ? () => _confirmDelete(context, i)
                      : null,
                  onTap: () => _openCopingCard(text),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.style_rounded,
                                color: Colors.teal,
                                size: 18,
                              ),
                            ),
                            const Spacer(),
                            if (isCustom)
                              const Chip(
                                label: Text('Custom'),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isCustom)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _confirmDelete(context, i),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Coping Card?'),
        content: const Text('This will delete your custom card.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeCustomAt(index);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openCopingCard(String text) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Coping Card',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink(); // child is built in transitionBuilder
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return Opacity(
          opacity: curve.value,
          child: Transform.scale(
            scale: 0.96 + 0.04 * curve.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.style_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Coping Card',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2A145D),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Got it'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

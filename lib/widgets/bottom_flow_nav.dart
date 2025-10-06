import 'package:flutter/material.dart';
import '../pages/relationship_pulse_page.dart';
import '../pages/emotional_check_in_entry_page.dart';
import '../pages/dr_iris_dashboard.dart';

/// Reusable bottom back/next navigation bar for linear beta flow.
class BottomFlowNav extends StatelessWidget {
  final String currentPageId;
  final EdgeInsets padding;
  const BottomFlowNav({super.key, required this.currentPageId, this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8)});

  // Ordered list of page identifiers that define the linear exploration flow
  // Update here (and the _buildNextWidget switch) if you add/remove pages.
  static const List<String> _flowOrder = [
    'GiftMarketplacePage',        // 1. Daily AI Pack / Marketplace hub
    'RelationshipPulsePage',      // 2. Relationship health segmentation
    'EmotionalCheckInEntryPage',  // 3. Log a new emotional check-in
    'DrIrisDashboard',            // 4. Dr. Iris contextual AI dashboard
  ];

  bool get _isFirst => _flowOrder.first == currentPageId;
  bool get _isLast => _flowOrder.last == currentPageId;

  Widget? _buildNextWidget(String id) {
    switch (id) {
      case 'GiftMarketplacePage':
        return const RelationshipPulsePage();
      case 'RelationshipPulsePage':
        return const EmotionalCheckInEntryPage();
      case 'EmotionalCheckInEntryPage':
        return const DrIrisDashboard();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _flowOrder.indexOf(currentPageId);
    final nextId = (idx >= 0 && idx < _flowOrder.length - 1) ? _flowOrder[idx + 1] : null;
    final nextWidget = nextId != null ? _buildNextWidget(currentPageId) : null;

    return SafeArea(
      top: false,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.25)) ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: Navigator.of(context).canPop() && !_isFirst
                    ? () => Navigator.of(context).pop()
                    : null,
                icon: const Icon(Icons.arrow_back_ios,size:16),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (_isLast || nextWidget == null)
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => nextWidget),
                        );
                      },
                icon: const Icon(Icons.arrow_forward_ios,size:16),
                label: Text(_isLast ? 'Done' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

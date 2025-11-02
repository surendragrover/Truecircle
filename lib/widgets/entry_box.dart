import 'package:flutter/material.dart';
import '../core/log_service.dart';

typedef EntryCallback = Future<void> Function(String text);

/// Small reusable entry box used across dashboard widgets for quick notes.
class EntryBox extends StatefulWidget {
  final String hintText;
  final EntryCallback? onSubmit;
  final String submitLabel;

  const EntryBox({
    super.key,
    this.hintText = 'Write a quick note...',
    this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<EntryBox> createState() => _EntryBoxState();
}

class _EntryBoxState extends State<EntryBox> {
  final TextEditingController _ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _busy = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(text);
      } else {
        // Default behaviour: log the entry for now
        LogService.instance.log('QuickEntry: $text');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved.')));
        _ctrl.clear();
      }
    } catch (e) {
      debugPrint('EntryBox submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save entry.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: widget.hintText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: _busy ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}

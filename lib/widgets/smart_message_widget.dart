import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../services/smart_message_service.dart';

class SmartMessageWidget extends StatefulWidget {
  final Contact contact;
  final VoidCallback? onMessageSent;

  const SmartMessageWidget({
    super.key,
    required this.contact,
    this.onMessageSent,
  });

  @override
  State<SmartMessageWidget> createState() => _SmartMessageWidgetState();
}

class _SmartMessageWidgetState extends State<SmartMessageWidget> {
  List<SmartMessage> smartMessages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateSmartMessages();
  }

  void _generateSmartMessages() {
    setState(() {
      isLoading = true;
    });

    // Simulate AI processing time
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        smartMessages =
            SmartMessageService.generateSmartMessages(widget.contact);
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (isLoading) _buildLoadingState(),
          if (!isLoading && smartMessages.isNotEmpty)
            _buildMessageSuggestions(),
          if (!isLoading && smartMessages.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.indigo.shade400],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Smart Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'स्मार्ट संदेश सुझाव',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _generateSmartMessages,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'नए सुझाव',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'AI आपके लिए perfect messages बना रहा है...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.contact.displayName} के लिए AI सुझाव:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...smartMessages.map((message) => _buildMessageCard(message)),
        ],
      ),
    );
  }

  Widget _buildMessageCard(SmartMessage message) {
    final personalizedMessage =
        SmartMessageService.personalizeMessage(message, widget.contact);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message category header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(message.category).withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  message.category.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  message.category.displayName,
                  style: TextStyle(
                    color: _getCategoryColor(message.category),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                _buildConfidenceIndicator(message.confidence),
              ],
            ),
          ),

          // Message content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personalizedMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI विश्लेषण: ${message.reasoning}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyMessage(personalizedMessage),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy करें'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendMessage(personalizedMessage),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('भेजें'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    Color color;
    String label;

    if (confidence >= 0.8) {
      color = Colors.green;
      label = 'Perfect';
    } else if (confidence >= 0.6) {
      color = Colors.orange;
      label = 'Good';
    } else {
      color = Colors.red;
      label = 'OK';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.message,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'कोई smart message उपलब्ध नहीं',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(MessageCategory category) {
    switch (category) {
      case MessageCategory.reconnection:
        return Colors.blue;
      case MessageCategory.boost:
        return Colors.purple;
      case MessageCategory.mutuality:
        return Colors.orange;
      case MessageCategory.occasion:
        return Colors.pink;
      case MessageCategory.cultural:
        return Colors.green;
      case MessageCategory.celebration:
        return Colors.amber;
      case MessageCategory.concern:
        return Colors.indigo;
    }
  }

  void _copyMessage(String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Message copied! 📋'),
          ],
        ),
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendMessage(String message) {
    // This would integrate with actual messaging services
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.send, color: Colors.white),
            SizedBox(width: 8),
            Text('Message sent successfully! 📤'),
          ],
        ),
        backgroundColor: Colors.blue.shade400,
        duration: const Duration(seconds: 2),
      ),
    );

    if (widget.onMessageSent != null) {
      widget.onMessageSent!();
    }
  }
}

class SmartMessageBottomSheet extends StatelessWidget {
  final Contact contact;

  const SmartMessageBottomSheet({
    super.key,
    required this.contact,
  });

  static void show(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartMessageBottomSheet(contact: contact),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SmartMessageWidget(
              contact: contact,
              onMessageSent: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

/// Daily inspirational quotes widget
class InspirationalQuoteWidget extends StatefulWidget {
  const InspirationalQuoteWidget({super.key});

  @override
  State<InspirationalQuoteWidget> createState() =>
      _InspirationalQuoteWidgetState();
}

class _InspirationalQuoteWidgetState extends State<InspirationalQuoteWidget> {
  int currentQuoteIndex = 0;

  final List<QuoteItem> quotes = [
    QuoteItem(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      color: Color(0xFF6366F1),
    ),
    QuoteItem(
      text:
          "Your emotional health is just as important as your physical health.",
      author: "Emotional Health Advocate",
      color: Color(0xFF14B8A6),
    ),
    QuoteItem(
      text:
          "Healing isn't about forgetting the past, but finding peace with it.",
      author: "TrueCircle Wisdom",
      color: Color(0xFF8B5CF6),
    ),
    QuoteItem(
      text: "Every small step forward is still progress.",
      author: "Wellness Journey",
      color: Color(0xFFF4AB37),
    ),
    QuoteItem(
      text: "You are stronger than you think and more loved than you know.",
      author: "Self-Care Reminder",
      color: Color(0xFFEC407A),
    ),
    QuoteItem(
      text: "Mindfulness is about being fully awake in our lives.",
      author: "Jon Kabat-Zinn",
      color: Color(0xFF66BB6A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Show random quote initially
    currentQuoteIndex = Random().nextInt(quotes.length);
  }

  @override
  Widget build(BuildContext context) {
    final quote = quotes[currentQuoteIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Inspiration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A145D), // Deep Purple
              ),
            ),
            GestureDetector(
              onTap: _showNextQuote,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: quote.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: quote.color,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(currentQuoteIndex),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  quote.color.withValues(alpha: 0.1),
                  quote.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: quote.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: quote.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.format_quote_rounded,
                    color: quote.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // Quote Text
                Text(
                  quote.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2A145D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Author
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: quote.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '— ${quote.author}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: quote.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNextQuote() {
    setState(() {
      currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
    });
  }
}

/// Quote item data class
class QuoteItem {
  final String text;
  final String author;
  final Color color;

  QuoteItem({required this.text, required this.author, required this.color});
}

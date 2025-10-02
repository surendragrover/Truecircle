// TrueCircle UI Visibility Fix
// This file contains fixes for text visibility and avatar display issues

import 'package:flutter/material.dart';

class UIVisibilityFix {
  // Fixed text styles with high contrast
  static const TextStyle highContrastTitle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static const TextStyle highContrastSubtitle = TextStyle(
    color: Colors.black87,
    fontSize: 16,
  );

  static const TextStyle whiteTextTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
        color: Colors.black54,
      ),
    ],
  );

  static const TextStyle whiteTextSubtitle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
        color: Colors.black54,
      ),
    ],
  );

  // Fixed avatar widget
  static Widget buildAvatarWithFallback({
    required double size,
    String? imagePath,
    String fallbackEmoji = '👩‍⚕️',
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: imagePath != null
          ? ClipOval(
              child: Image.asset(
                imagePath,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      fallbackEmoji,
                      style: TextStyle(fontSize: size * 0.5),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                fallbackEmoji,
                style: TextStyle(fontSize: size * 0.5),
              ),
            ),
    );
  }

  // Fixed logo with better visibility
  static Widget buildLogoWithHighVisibility({
    required double size,
    bool showText = true,
    bool isDarkBackground = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF8B5CF6),
                Color(0xFFF59E0B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'TC',
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'TrueCircle',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
              color: isDarkBackground ? Colors.white : Colors.black,
              shadows: isDarkBackground
                  ? [
                      const Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            'Emotional Intelligence',
            style: TextStyle(
              fontSize: size * 0.08,
              color: isDarkBackground
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black54,
              shadows: isDarkBackground
                  ? [
                      const Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

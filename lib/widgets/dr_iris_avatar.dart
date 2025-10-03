import 'package:flutter/material.dart';

class DrIrisAvatar extends StatelessWidget {
  final double size;
  final bool showName;
  final bool isHindi;

  const DrIrisAvatar({
    super.key,
    this.size = 60,
    this.showName = true,
    this.isHindi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFFA29BFE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to neutral gradient + medical emoji if image not found
                return Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C5CE7),
                        Color(0xFFA29BFE),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '👩‍⚕️',
                      style: TextStyle(fontSize: size * 0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isHindi ? 'डॉ. आइरिस' : 'Dr. Iris',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                isHindi ? 'आपका इमोशनल थेरेपिस्ट' : 'Your Emotional Therapist',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

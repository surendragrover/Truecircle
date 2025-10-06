import 'package:flutter/material.dart';

/// Global navigation bar for TrueCircle app
class GlobalNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showBack;
  final VoidCallback? onBack;

  const GlobalNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBack && onBack != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                onPressed: onBack,
                tooltip: 'Back',
              ),
            ),
          ),
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}

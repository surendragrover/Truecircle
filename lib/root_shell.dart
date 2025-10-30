import 'package:flutter/material.dart';
import 'dart:ui';
import 'home/home_page.dart';
import 'cbt/cbt_hub_page.dart';
import 'iris/dr_iris_welcome_page.dart';
import 'widgets/coin_display_widget.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const CBTHubPage(),
      const DrIrisWelcomePage(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),
          // Daily login reward checker - checks for reward on app startup
          const DailyLoginChecker(userId: 'default_user'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.white,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: Colors.grey.shade600,
                    ),
                    selectedIcon: _GradientIcon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.psychology_outlined,
                      color: Colors.grey.shade600,
                    ),
                    selectedIcon: _GradientIcon(Icons.psychology),
                    label: 'CBT',
                  ),
                  NavigationDestination(
                    icon: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade600,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.smart_toy_outlined,
                              color: Colors.grey.shade600,
                              size: 16,
                            );
                          },
                        ),
                      ),
                    ),
                    selectedIcon: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.smart_toy,
                              color: Colors.white,
                              size: 16,
                            );
                          },
                        ),
                      ),
                    ),
                    label: 'Dr. Iris',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  const _GradientIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    const colors = <Color>[
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ];
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

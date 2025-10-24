import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'cbt/cbt_hub_page.dart';
import 'iris/dr_iris_welcome_page.dart';
import 'more/more_page.dart';

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
      const MorePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFF8C00), // Kesari color
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.white24,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600);
                }
                return const TextStyle(color: Colors.white70, fontSize: 12);
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white70), 
                selectedIcon: Icon(Icons.home, color: Colors.white),
                label: 'Home'
              ),
              NavigationDestination(
                icon: Icon(Icons.hub_outlined, color: Colors.white70), 
                selectedIcon: Icon(Icons.hub, color: Colors.white),
                label: 'CBT'
              ),
              NavigationDestination(
                icon: Icon(Icons.psychology_alt_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.psychology_alt, color: Colors.white),
                label: 'Dr. Iris',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz, color: Colors.white70),
                selectedIcon: Icon(Icons.more_horiz, color: Colors.white),
                label: 'More'
              ),
            ],
          ),
        ),
      ),
    );
  }
}

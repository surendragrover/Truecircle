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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'CBT'),
          NavigationDestination(
            icon: Icon(Icons.psychology_alt_outlined),
            label: 'Dr. Iris',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

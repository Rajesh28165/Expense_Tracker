import 'package:flutter/material.dart';
import '../../constants/extension.dart';
import '../../router/route_name.dart';
import '../../router/route_path.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<String> _routes = [
    RouteName.dashboard,
    RouteName.report,
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    authNavigatorKey.currentState!.pushNamed(_routes[index]);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: authNavigatorKey,
        initialRoute: RouteName.dashboard,
        onGenerateRoute: AuthenticatedRouter.generate,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

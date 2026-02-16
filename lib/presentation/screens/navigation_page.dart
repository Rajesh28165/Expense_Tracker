import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_name.dart';

class NavigationPage extends StatefulWidget {
  final Widget child;

  const NavigationPage({super.key, required this.child});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<String> _routes = [
    RouteName.dashboard,
    RouteName.expenseReport,
    RouteName.incomeReport
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;

    _currentIndex = _routes.indexWhere(location.startsWith);
    if (_currentIndex == -1) _currentIndex = 0;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
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
            label: 'Expense Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Income Reports',
          ),
        ],
      ),
    );
  }
}

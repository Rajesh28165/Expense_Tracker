import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_name.dart';

class NavigationPage extends StatelessWidget {
  final Widget child;

  const NavigationPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;

    if (location.startsWith(RouteName.dashboard)) {
      currentIndex = 0;
    } else if (location.startsWith(RouteName.expenseReport)) {
      currentIndex = 1;
    } else if (location.startsWith(RouteName.incomeReport)) {
      currentIndex = 2;
    }

    void onTabTapped(int index) {
      switch (index) {
        case 0:
          context.go(RouteName.dashboard);
          break;
        case 1:
          context.go(RouteName.expenseReport);
          break;
        case 2:
          context.go(RouteName.incomeReport);
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
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
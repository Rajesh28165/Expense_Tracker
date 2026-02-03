import 'package:expense_tracker/presentation/screens/profile_page.dart';
import 'package:expense_tracker/presentation/screens/registeration_page.dart';
import 'package:expense_tracker/presentation/screens/security_page.dart';
import 'package:expense_tracker/presentation/screens/dashboard_page.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/add_expense_page.dart';
import '../presentation/screens/home_page.dart';
import '../presentation/screens/login_page.dart';
import '../presentation/screens/navigation_page.dart';
import '../presentation/screens/reports_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case RouteName.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );

      case RouteName.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case RouteName.registeration:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterationPage(),
        );

      case RouteName.security:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SecurityPage(),
        );

      case RouteName.navigation:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NavigationPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}


class AuthenticatedRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {

      case RouteName.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardPage(),
        );

      case RouteName.addExpense:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddExpensePage(),
        );

      case RouteName.report:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ReportsPage(),
        );

      case RouteName.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}


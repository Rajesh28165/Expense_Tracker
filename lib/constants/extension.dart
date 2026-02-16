import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/util/logger.dart';

final log = logger(BuildContext);


extension BuildContextExtensionFunctions on BuildContext {
  // ---------- UI Helpers ----------
  double getWidth() => MediaQuery.of(this).size.width;
  double getHeight() => MediaQuery.of(this).size.height;
  double getPercentWidth(double percentage) => getWidth() * percentage * 0.01;
  double getPercentHeight(double percentage) => getHeight() * percentage * 0.01;

  // ---------- GoRouter Navigation ----------
  void goTo(String route) {
    try {
      go(route);
    } catch (e) {
      log.e("GoRouter goTo failed → $route | $e");
    }
  }

  void pushTo(String route, {Object? extra}) {
    try {
      push(route, extra: extra);
    } catch (e) {
      log.e("GoRouter pushTo failed → $route | $e");
    }
  }

  void back() {
    if (canPop()) {
      pop();
    } else {
      log.e("Nothing to pop");
    }
  }

  // ---------- Helpers ----------
  String get currentRoute => GoRouterState.of(this).matchedLocation;

  bool isOn(String route) => currentRoute == route;
}

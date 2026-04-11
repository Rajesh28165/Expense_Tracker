import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


extension BuildContextExtensionFunctions on BuildContext {
  // ---------- UI Helpers ----------
  double getWidth() => MediaQuery.of(this).size.width;
  double getHeight() => MediaQuery.of(this).size.height;
  double getPercentWidth(double percentage) => getWidth() * percentage * 0.01;
  double getPercentHeight(double percentage) => getHeight() * percentage * 0.01;

  // ---------- GoRouter Navigation ----------
  void goTo(String route, {Object? extra}) {
    try {
      go(route, extra: extra);
    } catch (e) {}
  }

  void pushTo(String route, {Object? extra}) {
    try {
      push(route, extra: extra);
    } catch (e) {}
  }

  void back() {
    if (canPop()) {
      pop();
    }
  }

  // ---------- Helpers ----------
  String get currentRoute => GoRouterState.of(this).matchedLocation;

  bool isOn(String route) => currentRoute == route;
}

import 'package:expense_tracker/util/logger.dart';
import 'package:flutter/cupertino.dart';

final log = logger(BuildContext);

/// ✅ SINGLE SOURCE OF TRUTH (already used in main.dart & NavigationPage)
final GlobalKey<NavigatorState> unauthNavigatorKey =
    GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> authNavigatorKey =
    GlobalKey<NavigatorState>();

// -----------------------------------------------------------------------------
// String Extensions
// -----------------------------------------------------------------------------
extension StringExtensions on String {
  String capitalize() {
    if (trim().isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(' ')
        .map((word) =>
            word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
        .join(' ');
  }

  String toSentenceCase() {
    if (trim().isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

// -----------------------------------------------------------------------------
// BuildContext Extensions (NAVIGATION SAFE)
// -----------------------------------------------------------------------------
extension BuildContextExtensionFunctions on BuildContext {
  double getWidth() => MediaQuery.of(this).size.width;
  double getHeight() => MediaQuery.of(this).size.height;
  double getPercentWidth(double percentage) => getWidth() * percentage * 0.01;
  double getPercentHeight(double percentage) => getHeight() * percentage * 0.01;

  // ------------------ Internal helpers ------------------
  void _safePop({bool useRoot = false, bool? result}) {
    if (Navigator.canPop(this)) {
      Navigator.of(this, rootNavigator: useRoot).pop(result);
    } else {
      log.e("No Navigator found to pop");
    }
  }

  void _pushNamed(
    GlobalKey<NavigatorState> key,
    String routeName, {
    Object? arguments,
  }) {
    key.currentState?.pushNamed(routeName, arguments: arguments) ??
        log.e("Navigator not ready to push '$routeName'");
  }

  void _pushNamedAndRemoveUntil(
    GlobalKey<NavigatorState> key,
    String routeName, {
    Object? arguments,
  }) {
    key.currentState?.pushNamedAndRemoveUntil(
          routeName,
          (_) => false,
          arguments: arguments,
        ) ??
        log.e("Navigator not ready to pushAndRemoveUntil '$routeName'");
  }

  void _popUntil(GlobalKey<NavigatorState> key, String routeName) {
    final navState = key.currentState;
    if (navState != null) {
      navState.popUntil(ModalRoute.withName(routeName));
    } else {
      log.e("Navigator not ready to pop to '$routeName'");
    }
  }

  // ------------------ Public methods ------------------
  void popTrue({bool useRoot = false}) =>
      _safePop(useRoot: useRoot, result: true);

  void popFalse({bool useRoot = false}) =>
      _safePop(useRoot: useRoot, result: false);

  /// Default (context-based)
  void pushNamed(String routeName, {Object? arguments}) {
    try {
      Navigator.pushNamed(this, routeName, arguments: arguments);
    } catch (e) {
      log.e("Failed to pushNamed '$routeName': $e");
    }
  }

  // ------------------ Unauthenticated Navigator ------------------
  void pushNamedUnAuthenticated(String routeName, {Object? arguments}) =>
      _pushNamed(unauthNavigatorKey, routeName, arguments: arguments);

  void pushNamedUnAuthenticatedAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) =>
      _pushNamedAndRemoveUntil(
        unauthNavigatorKey,
        routeName,
        arguments: arguments,
      );

  void popRouteUnAuthenticated(String routeName) =>
      _popUntil(unauthNavigatorKey, routeName);

  // ------------------ Authenticated Navigator ------------------
  void pushNamedAuthenticated(String routeName, {Object? arguments}) =>
      _pushNamed(authNavigatorKey, routeName, arguments: arguments);

  void pushNamedAuthenticatedAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) =>
      _pushNamedAndRemoveUntil(
        authNavigatorKey,
        routeName,
        arguments: arguments,
      );

  void popRouteAuthenticated(String routeName) =>
      _popUntil(authNavigatorKey, routeName);
}

import 'package:expense_tracker/util/logger.dart';
import 'package:flutter/cupertino.dart';

final log = logger(BuildContext);

extension StringExtensions on String {
  /// Capitalizes only the first letter of a single word
  String capitalize() {
    if (trim().isEmpty) return this;

    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Converts a full sentence to Title Case
  String toTitleCase() {
    if (trim().isEmpty) return this;

    return split(' ').map(
      (word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : ''
      ).join(' ');
  }

  /// Capitalizes the first letter of the entire sentence only once
  String toSentenceCase() {
    if (trim().isEmpty) return this;

    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
  
}


extension BuildContextExtensionFunctions on BuildContext {

  double getWidth() => MediaQuery.of(this).size.width;

  double getHeight() => MediaQuery.of(this).size.height;

  double getPercentWidth(double percentage) => getWidth() * percentage * 0.01;

  double getPercentHeight(double percentage) => getHeight() * percentage * 0.01;

  /// Global navigator keys
  static final navigatorUnauthenticated = GlobalKey<NavigatorState>();
  static final navigatorAuthenticated = GlobalKey<NavigatorState>();

  // ------------------ Internal helpers ------------------
  void _safePop({bool useRoot = false, bool? result}) {
    if (Navigator.canPop(this)) {
      Navigator.of(this, rootNavigator: useRoot).pop(result);
    } else {
      log.e("No Navigator found to pop");
    }
  }

  void _pushNamed(GlobalKey<NavigatorState> key, String routeName, {Object? arguments}) {
    key.currentState?.pushNamed(routeName, arguments: arguments)
      ?? log.e("Navigator not ready to push '$routeName'");
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
  void popTrue({bool useRoot = false}) => _safePop(useRoot: useRoot, result: true);
  void popFalse({bool useRoot = false}) => _safePop(useRoot: useRoot, result: false);

  void pushNamed(String routeName, {Object? arguments}) {
    try {
      Navigator.pushNamed(this, routeName, arguments: arguments);
    } catch (e) {
      log.e("Failed to pushNamed '$routeName': $e");
    }
  }

  void pushAndRemoveUntil(String routeName, {Object? arguments}) {
    try {
      Navigator.of(this).pushNamedAndRemoveUntil(
        routeName,
        (_) => false,
        arguments: arguments,
      );
    } catch (e) {
      log.e("Failed to pushAndRemoveUntil '$routeName': $e");
    }
  }

  void pushNamedUnAuthenticated(String routeName, {Object? arguments}) =>
      _pushNamed(navigatorUnauthenticated, routeName, arguments: arguments);

  void popRouteUnAuthenticated(String routeName) =>
      _popUntil(navigatorUnauthenticated, routeName);

  void pushNamedAuthenticated(String routeName, {Object? arguments}) =>
      _pushNamed(navigatorAuthenticated, routeName, arguments: arguments);

  void popRouteAuthenticated(String routeName) =>
      _popUntil(navigatorAuthenticated, routeName);
}


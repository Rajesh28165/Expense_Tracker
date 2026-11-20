import 'package:logger/logger.dart';

Logger logger(Type type) => Logger(
  level: Level.debug, 
  printer: CustomerPrinter(type.toString())
);

class CustomerPrinter extends LogPrinter {
  final String className;
  CustomerPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    DateTime dateTime = DateTime.now();
    final color = levelColors[event.level]!;
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;
    return [color('$emoji [$dateTime] [$className]: [$message]')];
  }

  static final levelColors = {
    Level.debug: const AnsiColor.fg(184),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
  };
}

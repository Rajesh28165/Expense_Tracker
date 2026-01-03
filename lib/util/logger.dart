import 'package:logger/logger.dart';

Logger logger(Type type) {
  return Logger(
    level: Level.debug,
    printer: CustomPrinter(type.toString()),
  );
}

class CustomPrinter extends LogPrinter {
  final String className;
  CustomPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    final dateTime = DateTime.now().toIso8601String();
    final color = levelColors[event.level]!;
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level] ?? '';
    final message = event.message;

    return [
      color('$emoji [$dateTime] [$className]: $message'),
    ];
  }

  static final levelColors = {
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: const AnsiColor.fg(184),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
    Level.fatal: const AnsiColor.fg(199),
  };
}

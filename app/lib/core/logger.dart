/// Centralized logging infrastructure for SolarPlanner.
///
/// Provides a singleton [AppLogger] with log levels (debug, info, warn, error)
/// and optional file output for crash diagnostics.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  late Logger _logger;
  bool _fileOutputEnabled = false;
  File? _logFile;

  factory AppLogger() => _instance;

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(methodCount: 2, colors: true),
      output: _ConsoleOutput(),
    );
  }

  static AppLogger get instance => _instance;

  /// Enable/disable file-based log output.
  static void enableFileOutput(bool enabled) {
    _instance._fileOutputEnabled = enabled;
    if (enabled && _instance._logFile == null) {
      _instance._initLogFile();
    } else if (!enabled) {
      _instance._logFile = null;
    }
  }

  Future<void> _initLogFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/solar_planner.log');
    } catch (_) {
      // If we can't get the directory, fall back to system temp.
      _logFile = File('${Directory.systemTemp.path}/solar_planner.log');
    }
  }

  void debug(Object? message, {DateTime? time}) => _log(message, Level.debug, time: time);
  void info(Object? message, {DateTime? time}) => _log(message, Level.info, time: time);
  void warn(Object? message, {DateTime? time}) => _log(message, Level.warning, time: time);
  void error(Object? message, {DateTime? time, StackTrace? stackTrace}) => _log(message, Level.error, time: time, stackTrace: stackTrace);
  void fatal(Object? message, {DateTime? time, StackTrace? stackTrace}) => _log(message, Level.fatal, time: time, stackTrace: stackTrace);

  void _log(Object? message, Level level, {DateTime? time, StackTrace? stackTrace}) {
    // Console output via the logger instance
    _logger.log(level, message, time: time, stackTrace: stackTrace);

    // File output if enabled
    if (_fileOutputEnabled && _logFile != null) {
      try {
        final timestamp = time?.toUtc().toString() ?? DateTime.now().toUtc().toString();
        _logFile!.writeAsStringSync('[$timestamp] $level: $message\n', mode: FileMode.append);
      } catch (_) {
        // Silently ignore file write failures — don't crash the app over logging.
      }
    }
  }
}

/// A simple console-only LogOutput that delegates to print.
class _ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

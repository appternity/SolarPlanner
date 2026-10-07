import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/logger.dart';

void main() {
  test('AppLogger singleton returns same instance', () {
    final a = AppLogger.instance;
    final b = AppLogger.instance;
    expect(identical(a, b), isTrue);
  });

  test('AppLogger methods do not throw', () {
    final logger = AppLogger.instance;
    expect(() => logger.debug('test'), returnsNormally);
    expect(() => logger.info('test'), returnsNormally);
    expect(() => logger.warn('test'), returnsNormally);
    expect(() => logger.error('test'), returnsNormally);
  });

  test('enableFileOutput setter does not throw', () {
    expect(() => AppLogger.enableFileOutput(true), returnsNormally);
    expect(() => AppLogger.enableFileOutput(false), returnsNormally);
  });

  test('Logger methods handle null messages', () {
    final logger = AppLogger.instance;
    expect(() => logger.debug(null), returnsNormally);
    expect(() => logger.info(null), returnsNormally);
    expect(() => logger.error(null), returnsNormally);
  });

  test('Logger handles long messages without crashing', () {
    final logger = AppLogger.instance;
    final longMessage = 'x' * 10000;
    expect(() => logger.info(longMessage), returnsNormally);
  });
}

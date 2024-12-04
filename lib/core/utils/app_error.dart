import 'package:flutter/material.dart';

class AppErrorBase {
  final List<dynamic>? args;
  final String? message;
  final String? source;
  final String? error;
  final String name;
  final String? stackTrace;
  final bool sendToTg;

  AppErrorBase(this.message,
      {required this.name,
      required this.sendToTg,
      this.args,
      this.source,
      this.error,
      this.stackTrace}) {
    debugPrint(toString());
  }
  @override
  String toString() {
    return 'AppErrorBase: $message\nSource: $source\nName: $name\nError: $error\nArgs: $args\nStackTrace: $stackTrace';
  }
}

class AppLogger {
  static void log(AppErrorBase error) {
    debugPrint(error.toString());
    if (error.sendToTg) {
      sendToTelegram(error);
    }
  }

  static Future<void> sendToTelegram(AppErrorBase error) async {
    debugPrint('Telegram log: ${error.message}');
  }
}

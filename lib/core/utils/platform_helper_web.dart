import 'package:flutter/foundation.dart';

/// Web stub - database not supported on web
Future<void> initializeDatabaseFactory() async {
  debugPrint('Web platform - SQLite database not supported');
}

/// Database is not supported on web
bool get isDatabaseSupported => false;

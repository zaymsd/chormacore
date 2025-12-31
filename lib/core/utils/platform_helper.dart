import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Check if running on desktop platform
bool get isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

/// Initialize database for the current platform
Future<void> initializeDatabaseFactory() async {
  if (kIsWeb) {
    debugPrint('Web platform - database not supported');
    return;
  }

  if (isDesktop) {
    // Initialize FFI only for desktop platforms (Windows, macOS, Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    debugPrint('Database initialized for desktop using FFI');
  } else {
    // Android and iOS use built-in SQLite, no FFI needed
    debugPrint('Database initialized for mobile (using native SQLite)');
  }
}

/// Check if database is supported on current platform
bool get isDatabaseSupported => !kIsWeb;

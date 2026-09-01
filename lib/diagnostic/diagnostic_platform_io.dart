import 'dart:io' show Platform;

/// Returns true when running on Android (dart:io implementation).
bool isAndroidPlatform() => Platform.isAndroid;

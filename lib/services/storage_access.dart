import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Access to the tablet's shared storage, where Register Interest leads are
/// saved (`Internal storage/Ezdihar-Mashael Al Fursan`, see `LeadStore`).
///
/// The app does not start without it: while [granted] is false, `MyApp` shows
/// the storage access screen, and [request] closes the app when access is
/// refused, so it is asked again on the next open.
///
/// Android 11 and later: "All files access" (the system settings page for the
/// app); Android 10 and earlier: the storage permission dialog. Other
/// platforms keep the leads in the app's documents folder: always granted.
class StorageAccess extends ChangeNotifier {
  StorageAccess({
    required bool granted,
    Future<bool> Function()? request,
    Future<void> Function()? close,
  })  : _granted = granted,
        _request = request ?? _requestPlatform,
        _close = close ?? SystemNavigator.pop;

  /// Reads the current state; call once before `runApp`.
  static Future<StorageAccess> load() async => StorageAccess(granted: await _checkPlatform());

  bool _granted;
  final Future<bool> Function() _request;
  final Future<void> Function() _close;

  bool get granted => _granted;

  /// Asks for access. Granted: the app starts. Refused: the app closes.
  Future<void> request() async {
    if (await _request()) {
      _granted = true;
      notifyListeners();
    } else {
      await _close();
    }
  }

  static Future<bool> _checkPlatform() async {
    if (!Platform.isAndroid) return true;
    // "All files access" is reported as restricted below Android 11.
    final allFiles = await Permission.manageExternalStorage.status;
    return allFiles.isRestricted ? Permission.storage.isGranted : allFiles.isGranted;
  }

  static Future<bool> _requestPlatform() async {
    if (!Platform.isAndroid) return true;
    if (!(await Permission.manageExternalStorage.status).isRestricted) {
      // Opens the app's "All files access" settings page; completes on return.
      return (await Permission.manageExternalStorage.request()).isGranted;
    }
    final status = await Permission.storage.request();
    // After "Don't ask again" the dialog no longer shows: the permission can
    // only be switched on in the app's settings, which are opened for it.
    if (status.isPermanentlyDenied) await openAppSettings();
    return status.isGranted;
  }
}

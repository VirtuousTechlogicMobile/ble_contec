import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

/// permission type
enum PermissionType {
  // Read External Storage (Android)
  storage,

  // Write External Storage (Android)
  manageExternalStorage,

  // Access Coarse Location (Android) / When In Use iOS
  accessCoarseLocation,

  // Access Fine Location (Android) / When In Use iOS
  accessFineLocation,

  // Access Fine Location (Android) / When In Use iOS
  whenInUseLocation,

  // Access Fine Location (Android) / Always Location iOS
  alwaysLocation,

  // Location Permission
  location,

  // Bluetooth Connect
  bluetoothConnect
}

class PermissionRequestManager {
  PermissionType? _permissionType;
  Function(PermissionStatus status)? _onPermissionDenied;
  Function(PermissionStatus status)? _onPermissionGranted;
  Function(PermissionStatus status)? _onPermissionPermanentlyDenied;

  PermissionRequestManager(PermissionType permissionType) {
    _permissionType = permissionType;
  }

  /// on Permission Denied
  PermissionRequestManager onPermissionDenied(
      Function(PermissionStatus status)? onPermissionDenied) {
    _onPermissionDenied = onPermissionDenied;
    return this;
  }

  /// on Permission Granted
  PermissionRequestManager onPermissionGranted(
      Function(PermissionStatus status)? onPermissionGranted) {
    _onPermissionGranted = onPermissionGranted;

    return this;
  }

  /// on Permission Permanently Denied
  PermissionRequestManager onPermissionPermanentlyDenied(
      Function(PermissionStatus status)? onPermissionPermanentlyDenied) {
    _onPermissionPermanentlyDenied = onPermissionPermanentlyDenied;

    return this;
  }

  /// get Permission Type
  Permission _getPermissionFromType(PermissionType permissionType) {
    switch (permissionType) {
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.manageExternalStorage:
        return Permission.manageExternalStorage;
      case PermissionType.accessCoarseLocation:
        return Permission.locationAlways;
      case PermissionType.accessFineLocation:
        return Permission.locationAlways;
      case PermissionType.whenInUseLocation:
        return Permission.locationWhenInUse;
      case PermissionType.alwaysLocation:
        return Permission.locationAlways;
      case PermissionType.location:
        return Permission.locationAlways;
      case PermissionType.bluetoothConnect:
        return Permission.bluetoothConnect;
      default:
        throw Exception('Invalid permission type');
    }
  }

  /// request permissions
  Future<void> requestForPermissions(PermissionStatus permissionStatus) async {
    late PermissionStatus status;
    Permission permission = _getPermissionFromType(_permissionType!);
    if (permission == Permission.locationWhenInUse ||
        permission == Permission.locationAlways ||
        permission == Permission.location) {
      await permission.shouldShowRequestRationale;
    }
    status = await permission.request();
    debugPrint("permission status : $status");
    if (status.isGranted) {
      if (_onPermissionGranted != null) {
        _onPermissionGranted!(status);
      }
    } else if (status.isDenied) {
      if (_onPermissionDenied != null) {
        _onPermissionDenied!(status);
      }
    } else if (status.isPermanentlyDenied) {
      if (_onPermissionPermanentlyDenied != null) {
        _onPermissionPermanentlyDenied!(status);
      }
    }
  }
}

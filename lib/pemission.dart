import 'dart:io';

import 'package:flutter/services.dart';

import 'android_ble_contec.dart';
import 'ios_ble_contec.dart';

class Permission {
  static const platform = MethodChannel('com.contectcms.bluetooth_cms5');

  /// connect Method Channel Permission
  Future<void> _connectMethodChannelPermission(String method) async {
    String resultData = "";
    try {
      final result = await platform.invokeMethod<String>(method);
      resultData = '$result';
      if (resultData.contains("All permissions are granted")) {
        await _redirectToPage(Platform.isIOS ? true : false);
      } else {
        /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please Grant All Permissions"),
        ));*/
      }
    } on Exception catch (e) {
      resultData = 'Error ${e.toString()}';
    }
  }
  /// check android Or Iso device and redirect class
  Future _redirectToPage(bool isIos) async {
    isIos ? BluetoothDeviceConnectionIos() : BluetoothDeviceConnectionAndroid();
  }
}

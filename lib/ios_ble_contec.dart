import 'package:flutter/services.dart';

import 'connection_device.dart';

class BluetoothDeviceConnectionIos {
  static const platform = MethodChannel('com.contectcms.bluetooth_cms5');
  final List<String> _availableDevices = [];
  final List<String> _availableDevicesForName = [];

  /// connection Method channel
  Future _connectMethodChannel(String method, dynamic selectedDeviceName) async {
    dynamic resultData = "";
    final result;
    try {
      if (method == "connectDevice") {
        result = await platform.invokeMethod<dynamic>(method, <String, dynamic>{'selectedDevice': selectedDeviceName});
      } else {
        result = await platform.invokeMethod<dynamic>(method);
      }
      resultData = '$result';
    } on PlatformException catch (e) {
      resultData = 'Error ${e.code}';
    }
    //setState(() {
    switch (method) {
      case "startSearch":
        if (!resultData.contains("Bluetooth Not Supported")) {
          _availableDevices.add(resultData);
          if (resultData != null) {
            const start = "name =";
            const end = ", mtu";
            final startIndex = resultData.indexOf(start);
            final endIndex = resultData.indexOf(end, startIndex + start.length);
            String deviceName = resultData.substring(startIndex + start.length, endIndex);
            _availableDevicesForName.add(deviceName);
          }
        } else {
          /*ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Bluetooth Not Supported on your device"),
              ),
            );*/
        }
        //setState(() {});
        break;
      case "connectDevice":
        if (resultData.contains("Connected")) {
          /// call class Connection Device
          ConnectionDevice();
        }
        break;
    }
    //});
  }

  /// checkPermissions
  Future<String> checkPermissions() async {
    return await _connectMethodChannel("checkPermissions","");
  }

  /// START SEARCH
  startSearch(dynamic selectedDeviceName) async {
    await _connectMethodChannel("startSearch", selectedDeviceName);
  }

  /// STOP SEARCH
  stopSearch(dynamic selectedDeviceName) async {
    await _connectMethodChannel("stopSearch", selectedDeviceName);
  }

  /// CONNECT DEVICE
  connectDevice(dynamic selectedDeviceName, String userId) async {
    await ConnectionDevice().initCSVFile(userID: userId);
    await _connectMethodChannel("connectDevice", selectedDeviceName);
  }

  /// DISCONNECT DEVICE
  disconnectDevice(dynamic selectedDeviceName) async {
    await _connectMethodChannel("disconnectDevice", selectedDeviceName);
  }

  /// DEVICE STATE
  getDeviceState(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getDeviceState", selectedDeviceName);
  }

  /// GET DEVICE BATTERY
  getBattery(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getBattery", selectedDeviceName);
  }

  /// GET DEVICE TIME
  getTime(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getTime", selectedDeviceName);
  }

  /// SET DEVICE TIME
  setTime(dynamic selectedDeviceName) async {
    await _connectMethodChannel("setTime", selectedDeviceName);
  }

  /// GET DEVICE FIRMWARE VERSION
  getFirmWareVersion(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getFirmWareVersion", selectedDeviceName);
  }

  /// GET SDK VERSION
  getSDKVersion(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getSDKVersion", selectedDeviceName);
  }

  /// DATA STATUS
  getDataStatus(dynamic selectedDeviceName) async {
    await _connectMethodChannel("getDataStatus", selectedDeviceName);
  }

  /// CANCEL DISCONNECT
  cancelDisconnect(dynamic selectedDeviceName) async {
    await _connectMethodChannel("cancelDisconnect", selectedDeviceName);
  }

  /// DELETE DATA
  deleteData(dynamic selectedDeviceName) async {
    await _connectMethodChannel("deleteData", selectedDeviceName);
  }

  /// SYNC DATA
  sync(dynamic selectedDeviceName) async {
    await _connectMethodChannel("sync", selectedDeviceName);
  }

  /// START REALTIME
  startRealtimeData(dynamic selectedDeviceName) async {
    await _connectMethodChannel("startRealtimeData", selectedDeviceName);
  }

  /// STOP REALTIME
  stopRealtimeData(dynamic selectedDeviceName) async {
    await _connectMethodChannel("stopRealtimeData", selectedDeviceName);
  }
}

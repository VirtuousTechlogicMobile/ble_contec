library ble_contec;

import 'dart:async';
import 'dart:io';
import 'package:ble_contec/permissionRequestManager.dart';
import 'package:flutter/services.dart';
// import 'package:package/permissionRequestManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothDeviceConnectionAndroid {
  String _tvStatus = "",
      _tvConnectStatus = "",
      _tvDeviceState = "",
      _tvGetBattery = "",
      _tvGetTime = "",
      _tvSetTime = "",
      _tvFirmwareVersion = "",
      _tvSDKVersion = "",
      _tvDataStatus = "",
      _tvCloseBluetooth = "",
      _tvDelete = "",
      _tvData = "";
  static const platform = MethodChannel('com.contectcms.bluetooth_cms5');

  bool isVisible = false, isShow = false, isRealTimeSync = false;

  String realTimeValue = "";

  static const eventChannel = EventChannel('getRealTimeDataEventChannel');
  late StreamSubscription _streamSubscription;

  late File fileToWriteCSV;

  PermissionStatus _storageStatus = PermissionStatus.denied;

  /// get real time sync data
  Future<void> getRealTimeSyncData() async {
    _streamSubscription =
        eventChannel.receiveBroadcastStream().listen(_listenRealTimeData);
  }

  /// listen real time data
  void _listenRealTimeData(realTimeData) {
    realTimeValue = realTimeData;
    fileToWriteCSV.writeAsStringSync(realTimeValue, flush: true);
    //setState(() {});
  }

  /// connection method channel Android
  Future _connectMethodChannel(String method) async {
    dynamic resultData = "";
    try {
      final result = await platform.invokeMethod<dynamic>(method);
      if (result
          .toString()
          .contains('Error1739.Receive realtime data failed.')) {
        /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please Click \"START REALTIME\" button to reload data"),
        ));*/
      } else {
        resultData = result;
      }
    } on PlatformException catch (e) {
      resultData = 'Error ${e.code}';
    }
    //setState(() {
    switch (method) {
      case "disconnectDevice":
        _tvStatus = resultData;
        break;
      case "getDeviceState":
        _tvDeviceState = resultData;
        break;
      case "getBattery":
        _tvGetBattery = resultData;
        break;
      case "getTime":
        _tvGetTime = resultData;
        break;
      case "setTime":
        _tvSetTime = resultData;
        break;
      case "getFirmWareVersion":
        _tvFirmwareVersion = resultData;
        break;
      case "getSDKVersion":
        _tvSDKVersion = resultData;
        break;
      case "getDataStatus":
        _tvDataStatus = resultData;
        break;
      case "cancelDisconnect":
        _tvCloseBluetooth = resultData;
        break;
      case "deleteData":
        _tvDelete = resultData;
        break;
      case "startRealtimeData":
        _tvData = resultData;
        getRealTimeSyncData();
        break;
      case "stopRealtimeData":
        _tvData = resultData;
        break;
    }
    //});
  }

  /// create csv file
  Future<void> initCSVFile({required String userID}) async {
    final myFilePath = (await getApplicationSupportDirectory()).path;
    String currentDate = DateFormat('dd_MM_yyyy').format(DateTime.now());
    final String myFileName =
        '$myFilePath/CMS50S_${userID}_${currentDate}_RealTimeData.csv';
    File fileToWriteCSV = File(myFileName);
    if (!fileToWriteCSV.existsSync()) {
      fileToWriteCSV.createSync();
    }
  }

  /// manage permissions
  Future<void> managePermissions() async {
    /// Ask this permission While Start Recording*
    PermissionRequestManager(PermissionType.storage)
        .onPermissionDenied((storageStatus) {
      _storageStatus = PermissionStatus.denied;
      /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Kindly Grant \"Storage\" Permission from Settings."),
      ));*/
      //PermissionRequestManager(PermissionType.storage).requestForPermissions();
    }).onPermissionGranted((storageStatus) {
      _storageStatus = PermissionStatus.granted;
      /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("\"Storage\" Permission Granted."),
      ));*/
      // _isStoragePermission = true;
    }).onPermissionPermanentlyDenied((storageStatus) {
      _storageStatus = PermissionStatus.permanentlyDenied;
      /*    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Kindly Grant \"Storage\" Permission from Settings."),
      ));*/
    }).requestForPermissions(_storageStatus);
  }

  /// checkPermissions
  Future<String> checkPermissions() async {
    return await _connectMethodChannel("checkPermissions");
  }

  /// START SEARCH
  startSearch() async {
    await _connectMethodChannel("startSearch");
  }

  /// STOP SEARCH
  stopSearch() async {
    await _connectMethodChannel("stopSearch");
  }

  /// CONNECT DEVICE
  connectDevice(String userId) async {
    /// user Id pass (discuss)
    await initCSVFile(userID: userId);
    await _connectMethodChannel("connectDevice");
  }

  /// DISCONNECT DEVICE
  disconnectDevice() async {
    await _connectMethodChannel("disconnectDevice");
  }

  /// DEVICE STATE
  getDeviceState() async {
    await _connectMethodChannel("getDeviceState");
  }

  /// GET DEVICE BATTERY
  getBattery() async {
    await _connectMethodChannel("getBattery");
  }

  /// GET DEVICE TIME
  getTime() async {
    await _connectMethodChannel("getTime");
  }

  /// SET DEVICE TIME
  setTime() async {
    await _connectMethodChannel("setTime");
  }

  /// GET DEVICE FIRMWARE VERSION
  getFirmWareVersion() async {
    await _connectMethodChannel("getFirmWareVersion");
  }

  /// GET SDK VERSION
  getSDKVersion() async {
    await _connectMethodChannel("getSDKVersion");
  }

  /// DATA STATUS
  getDataStatus() async {
    await _connectMethodChannel("getDataStatus");
  }

  /// CANCEL DISCONNECT
  cancelDisconnect() async {
    await _connectMethodChannel("cancelDisconnect");
  }

  /// DELETE DATA
  deleteData() async {
    await _connectMethodChannel("deleteData");
  }

  /// SYNC DATA
  sync() async {
    await _connectMethodChannel("sync");
  }

  /// START REALTIME
  startRealtimeData() async {
    await _connectMethodChannel("startRealtimeData");
  }

  /// STOP REALTIME
  stopRealtimeData() async {
    await _connectMethodChannel("stopRealtimeData");
  }
}

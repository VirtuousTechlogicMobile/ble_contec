import 'dart:async';
import 'dart:io';
import 'package:intl/src/intl/date_format.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ConnectionDevice {
  dynamic flutterResult;
  dynamic _tvStatus = "",
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

  bool isRealTimeSync = false;
  String realTimeValue = "";

  static const eventChannel = EventChannel('getRealTimeDataEventChannel');
  late StreamSubscription _streamSubscription;
  late File fileToWriteCSV;

  void getRealTimeSyncData() async {
    _streamSubscription =
        eventChannel.receiveBroadcastStream().listen(_listenRealTimeData);
  }

  void _listenRealTimeData(realTimeData) async {
    realTimeValue = realTimeData;
    fileToWriteCSV.writeAsStringSync(realTimeValue, flush: true);
    //setState(() {});
  }

  Future<void> _connectMethodChannel(String method) async {
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
}

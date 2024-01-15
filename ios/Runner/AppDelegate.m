#import "AppDelegate.h"
#import "ContecBluetoothSDK.h"
@import FirebaseCore;
#import "Firebase.h"
#import "GeneratedPluginRegistrant.h"

FlutterEventSink eventSinkRealTimeData;

@interface AppDelegate ()<ContecBluetoothDelegate>
@property(nonatomic, retain) NSMutableArray *devices;

@property(strong) CBPeripheral *per;

@property(nonatomic, retain) NSMutableArray *advDataDicAry;

@property(nonatomic, retain) UIActivityIndicatorView *aiv;

@property(nonatomic, retain) ContecBluetoothSDK *c_SDK;


@property FlutterResult flutterResultData;
@property FlutterEventChannel* eventChannel;
@property FlutterViewController *controller;
@property NSString *methodName;



@end

@implementation StreamHandler

NSDictionary * strRes;
NSString * finalRes;
- (instancetype)init:(NSDictionary *)dicData
{
    strRes = dicData;
    return self;
}
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    eventSinkRealTimeData = eventSink;
    NSLog(@"---- Event Channel Executed -----");
    NSLog(@"%@",strRes);
    NSString* piData = strRes[@"PI"];
    NSString* oxyData = strRes[@"oxygen"];
    NSString* pulseData = strRes[@"pulse"];
    finalRes = [NSString stringWithFormat:@"RealTimeData : PI: %@ Oxygen: %@ Pulse : %@", piData,oxyData,pulseData];
    eventSinkRealTimeData(@[finalRes]);
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    eventSinkRealTimeData = nil;
  return nil;
}

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *) launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
//    [FIRApp configure];
    self.c_SDK = [ContecBluetoothSDK sharedSingleton];
    self.c_SDK.delegate = self;
    self.controller = (FlutterViewController *) self.window.rootViewController;
    FlutterMethodChannel *methodChannelObj = [FlutterMethodChannel
            methodChannelWithName:@"com.contectcms.bluetooth_cms5"
                  binaryMessenger:self.controller.binaryMessenger];
    [methodChannelObj setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"startRealtimeData" isEqualToString:call.method]) {

            self.flutterResultData(@"Ok");
            self->_eventChannel =
                    [FlutterEventChannel eventChannelWithName:@"getRealTimeDataEventChannel"
                                              binaryMessenger:self.controller.binaryMessenger];
            [self manageRealTimeData:call.method andResult:result selecteDevice:call.arguments[@"selectedDevice"]];
        }
        else
        {
        [self callMethodAndGetData:call.method andResult:result selecteDevice:call.arguments[@"selectedDevice"]];

        }
    }];
    return YES;
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

-(void)addLogInFirebase:(NSString *)methodName andData:(NSString *) addedData {
    NSString *str_data = [NSString stringWithFormat:@"%@", methodName];
//    [FIRAnalytics logEventWithName:str_data
//                        parameters:@{
//                                     @"MethodName_": str_data,
//                                     @"Data_": addedData
//                                     }];
    NSLog(@"---- Add Log in Firebase Executed -----");
}

	
- (void)callMethodAndGetData:(NSString *)methodName andResult:(FlutterResult)resultData selecteDevice:(CBPeripheral *)deviceName {
    _flutterResultData = resultData;
    NSString *str_data = [NSString stringWithFormat:@"%@", methodName];
    NSLog(@"methodName is %@", str_data);
    NSString *str_data1 = [NSString stringWithFormat:@"%@", deviceName];
    NSLog(@"deviceName  %@", str_data1);
        if ([@"startSearch" isEqualToString:methodName]) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.devices = [NSMutableArray array];
        self.advDataDicAry = [NSMutableArray array];
    } else if ([@"connectDevice" isEqualToString:methodName]) {
        [self connectDeviceNow:deviceName];
    } else if ([@"disconnectDevice" isEqualToString:methodName]) {
        _methodName = methodName;
        [self cancelConnect];
    } else if ([@"getDeviceState" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getDeviceState];
    } else if ([@"getBattery" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getBatteryPower];
    } else if ([@"getTime" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getTime];
    } else if ([@"setTime" isEqualToString:methodName]) {
        _methodName = methodName;
        [self setTime];
    } else if ([@"getFirmWareVersion" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getDeviceFirmwareVersion];
    } else if ([@"getDataStatus" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getDataState];
    } else if ([@"cancelDisconnect" isEqualToString:methodName]) {
        _methodName = methodName;
        [self cancelConnect];
    } else if ([@"deleteData" isEqualToString:methodName]) {
        _methodName = methodName;
        [self deleteData];
    } else if ([@"stopRealtimeData" isEqualToString:methodName]) {
        _methodName = methodName;
        [self endReceiveRealtimeData];
    } else if ([@"getSDKVersion" isEqualToString:methodName]) {
        _methodName = methodName;
        [self getSDKVersion];
    }
//    else if ([@"startRealtimeData" isEqualToString:methodName]) {
//        [self startReceiveRealtimeData];
//    }

}

- (void)manageRealTimeData:(NSString *)methodName andResult:(FlutterResult)resultData
             selecteDevice:(CBPeripheral *)deviceName{

    [_c_SDK peripheral:_connectingPeripheral startReceiveRealtimeDataWithType:SpO2RealTimeDatatype_Value];


}

- (void)connectDeviceNow:(CBPeripheral *)deviceName {
    for (CBPeripheral* peri in self.devices)
    {
        if ([peri.name hasPrefix:@"SpO2119823"]) {
            self.per = peri;
            break;
        }
    }
    NSString *str_data = [NSString stringWithFormat:@"%@", self.per];
    NSString *str_data1 = [NSString stringWithFormat:@"%@", self.per.name];
    if ([str_data1 hasPrefix:@"SpO2119823"]) {
        NSDictionary* dic = @{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:YES]};
        [self addLogInFirebase:@"connectDeviceNow" andData: str_data1];
        [self.manager connectPeripheral:_per options:dic];
        [self.manager stopScan];
        _flutterResultData(@"Device Connected");

    } else {
        [self addLogInFirebase:@"NoSpO211Device_" andData: str_data1];
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"" message:@"No SpO211 Device" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [aler show];
        _flutterResultData(@"No SpO211 Device");
        
    }
}

#pragma mark ---< CBCentralManagerDelegate >---

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Hello : central.state = %ld", (long) central.state);

    if (central.state == CBCentralManagerStatePoweredOn) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [self.manager scanForPeripheralsWithServices:nil options:dic];
    } else {
        NSLog(@"Bluetooth Not Supported");
        [self addLogInFirebase:@"centralManagerDidUpdateState_" andData: @"Bluetooth Not Supported"];
        _flutterResultData(@"Bluetooth Not Supported");
    }
}

- (void)getAllAvailableDevices:(CBPeripheral *)peri {
    NSString *str_data = [NSString stringWithFormat:@"%@", peri];
    _flutterResultData(str_data);
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Hello : didDiscoverPeripheral");
    if (peripheral.name) {
        NSLog(@"Peripheral.name :%@ advertisementData :%@", peripheral.name, advertisementData);
    }
    if (![_devices containsObject:peripheral] && peripheral.name) {
        NSString *str_data = [NSString stringWithFormat:@"%lu", (unsigned long)_devices.count];
        [self addLogInFirebase:@"didDiscoverPeripheral_" andData: str_data];

        [_devices addObject:peripheral];

        [_advDataDicAry addObject:advertisementData];
        [self getAllAvailableDevices:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral - connected");
    [_aiv stopAnimating];

    NSString *selectedStr = _per.name;
    NSString *str_data = [NSString stringWithFormat:@"%@", selectedStr];
    NSLog(@"device name ", str_data);
    [self addLogInFirebase:@"didConnectPeripheral_" andData: str_data];
    if ([selectedStr hasPrefix:@"SpO211"]) {

        NSString *selectedStr = _per.name;
        NSString *str_data = [NSString stringWithFormat:@"%@", selectedStr];
        NSLog(@"device name ", str_data);
        self.connectingPeripheral = _per;
        _flutterResultData(@"Device Connected");


    } else {
        self.connectingPeripheral = _per;
        [self addLogInFirebase:@"NotSpO211Device_" andData: _per.name];
        _flutterResultData(@"Device Connected");
        

    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral,error:%@", error);
    NSString *str_data = [NSString stringWithFormat:@"%@", error];
    [self addLogInFirebase:@"didFailToConnectPeripheral_ %@" andData: str_data];

    [_aiv stopAnimating];

    UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [aler show];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral,error:%@", error);
    NSString *str_data = [NSString stringWithFormat:@"%@", error];
    [self addLogInFirebase:@"didDisconnectPeripheral_" andData:@"disconnect"];

    [_aiv stopAnimating];

    if (error) {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"连接已断开,error = %@", error] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];

        aler.tag = 1002;

        [aler show];
    }

}


- (void)deleteData {
    [self addLogInFirebase:@"deleteData_" andData: @"deleteData executed"];
    [_c_SDK peripheral:_connectingPeripheral deleteData:DeleteParameter_SpO2];
}

- (void)getDataState {
    [self addLogInFirebase:@"getDataState_" andData: @"getDataState executed"];
    [_c_SDK queryDeviceStateInfoFromPeripheral:_connectingPeripheral];
}

- (void)getDeviceState {
    [self addLogInFirebase:@"getDeviceState_" andData: @"getDeviceState executed"];
    [_c_SDK queryDataStateFromPeripheral:_connectingPeripheral];

}

- (void)getTime {
    NSLog(@"%s", __func__);
    [self addLogInFirebase:@"getTime_" andData: @"getTime executed"];
    [_c_SDK queryTimeFromPeripheral:_connectingPeripheral];

}

- (void)setTime {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *setDate = [dateFormatter stringFromDate:[NSDate date]];
//    //
//    NSLog(@"Date :: %@", setDate);
//    [_c_SDK synchronizeTime:setDate ToPeripheral:_connectingPeripheral];
//    [self addLogInFirebase:@"setTime_" andData: @"setTime executed"];

    NSDateFormatter * f = [[NSDateFormatter alloc] init];

    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate * date = [f dateFromString:@"2023-12-25 21:00:00"];
    
    [_c_SDK synchronizeTime:date ToPeripheral:_connectingPeripheral];
}

- (void)getBatteryPower {
    [self addLogInFirebase:@"getBatteryPower_" andData: @"getBatteryPower executed"];
    [_c_SDK queryBatteryPowerFromPeripheral:_connectingPeripheral];


}

- (void)getDeviceFirmwareVersion {
    [self addLogInFirebase:@"getDeviceFirmwareVersion_" andData: @"getDeviceFirmwareVersion executed"];
    [_c_SDK queryDeviceFirmwareVersionFromPeripheral:_connectingPeripheral];
}

- (void)startReceiveRealtimeData {
    [self addLogInFirebase:@"startReceiveRealtimeData_" andData: @"startReceiveRealtimeData executed"];
    [_c_SDK peripheral:_connectingPeripheral startReceiveRealtimeDataWithType:SpO2RealTimeDatatype_Value];


}

- (void)endReceiveRealtimeData {
    [self addLogInFirebase:@"endReceiveRealtimeData_" andData: @"endReceiveRealtimeData executed"];
    [_c_SDK endReceiveRealtimeDataWithPeripheral:_connectingPeripheral];

}


- (void)cancelConnect {
    [self addLogInFirebase:@"cancelConnectWithPeripheral_" andData: @"cancelConnectWithPeripheral executed"];
    [_c_SDK cancelConnectWithPeripheral:_connectingPeripheral];

}
- (void)getSDKVersion {
    [self addLogInFirebase:@"getSDKVersion" andData: @"SDKVersion executed"];
    NSString *str_data = [NSString stringWithFormat:@"SDK Version : %@", [_c_SDK SDKVersion]];
    _flutterResultData(@[str_data]);

}

#pragma mark --< ContecBluetoothDelegate >--

- (void)contec_getDeviceData:(NSDictionary *)dicDeviceData {

    NSLog(@"dicDeviceData = %@", dicDeviceData);
    NSString *str_data = [NSString stringWithFormat:@"%@", dicDeviceData];
    [self addLogInFirebase:@"contec_getDeviceData: Device Data is_" andData: str_data];

    _flutterResultData(@[str_data]);
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/50sdata.plist"];
//
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//
//        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//    }
//
//    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
//
//    BOOL bSuccess = [dicDeviceData writeToFile:path atomically:YES];
//
//    NSLog(@"bSuccess = %@", bSuccess ? @"成功" : @"失败");
}

- (void)contec_getOperateResult:(NSDictionary *)dicOperateResult {

    NSLog(@"dicOperateResult = %@", dicOperateResult);
    [self addLogInFirebase:@"dicOperateResult_" andData: dicOperateResult.description];
    NSString *str_res_data;
    NSString *str_data = [NSString stringWithFormat:@"%@", dicOperateResult];
    if ([@"disconnectDevice" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"OperateResult"];
        str_res_data = [NSString stringWithFormat:@"Status : %@", dataStatus];
    } else if ([@"getDeviceState" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"HaveData"];
        str_res_data = [NSString stringWithFormat:@"HaveData : %@", dataStatus];
    } else if ([@"getBattery" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"BatteryPower"];
        str_res_data = [NSString stringWithFormat:@"Battery : %@", dataStatus];
    } else if ([@"getTime" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"DeviceTime"];
        str_res_data = [NSString stringWithFormat:@"DeviceTime : %@", dataStatus];
    } else if ([@"setTime" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"OperateResult"];
        str_res_data = [NSString stringWithFormat:@"Status : %@", dataStatus];
    } else if ([@"getFirmWareVersion" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"ProgramVersion"];
        str_res_data = [NSString stringWithFormat:@"ProgramVersion : %@", dataStatus];
    } else if ([@"getDataStatus" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"StateInfo"];
        str_res_data = [NSString stringWithFormat:@"Data Status : %@", dataStatus];
    } else if ([@"cancelDisconnect" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"CancelState"];
        str_res_data = [NSString stringWithFormat:@"CancelState : %@", dataStatus];
    } else if ([@"deleteData" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"OperateResult"];
        str_res_data = [NSString stringWithFormat:@"Status : %@", dataStatus];
    } else if ([@"stopRealtimeData" isEqualToString:_methodName]) {
        id<NSObject> dataStatus = dicOperateResult[@"OperateResult"];
        str_res_data = [NSString stringWithFormat:@"Status : %@", dataStatus];
    }
    NSArray *allKeys = [dicOperateResult allKeys];

    if ([allKeys containsObject:@"CancelState"]) {

        if ([[dicOperateResult objectForKey:@"CancelState"] boolValue]) {

            NSLog(@"Cancel Connection Successfully - 取消连接成功");

        } else {

            NSLog(@"Failed to cancel connection - 取消连接失败");
        }
    }
    _flutterResultData(@[str_res_data]);
    
}

- (void)contec_getError:(NSDictionary *)dicError {

    NSLog(@"dicError = %@", dicError);
    NSString *str_data = [NSString stringWithFormat:@"%@", dicError];
    [self addLogInFirebase:@"contec_getError_" andData: str_data];
    _flutterResultData(@[str_data]);

}

- (void)contec_receivedRealtimeValueData:(NSDictionary *)valueDic {

    NSLog(@"%@", valueDic);
    NSString *str_data = [NSString stringWithFormat:@"%@", valueDic];
    [self addLogInFirebase:@"contec_receivedRealtimeValueData_" andData: @"Success Real Time Data"];
    StreamHandler* streamHandler =
    [[StreamHandler alloc] init:valueDic];;
    [self->_eventChannel setStreamHandler:streamHandler];
    []
}

- (void)contec_receivedRealtimeWaveData:(NSDictionary *)waveDic {

    NSLog(@"%@", waveDic);
    NSString *str_data = [NSString stringWithFormat:@"%@", waveDic];
    [self addLogInFirebase:@"contec_receivedRealtimeValueData_" andData: @"Success Wave Data"];
    StreamHandler* streamHandler =
    [[StreamHandler alloc] init:waveDic];
    self->_eventChannel =
            [FlutterEventChannel eventChannelWithName:@"getRealTimeDataEventChannel"
                                      binaryMessenger:self.controller.binaryMessenger];
    [self->_eventChannel setStreamHandler:streamHandler];
}

@end

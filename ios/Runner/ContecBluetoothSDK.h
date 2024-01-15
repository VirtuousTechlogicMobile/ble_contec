//
//  ContecBluetoothSDK.h
//  ContecBluetoothSDK
//
//  Created by CONTEC01 on 2020/1/15.
//  Copyright © 2020 CONTEC01. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "DataType.h"

/** ECG ***/
@interface ECGParameter : NSObject

@property (nonatomic, assign)ECGParameter_Language language;
@property (nonatomic, assign)ECGParameter_SaveTime saveTime;
@property (nonatomic, assign)ECGParameter_HearRateVoice voice;
@property (nonatomic, assign)ECGParameter_ShieldAnalysis shield;
@property (nonatomic, assign)ECGParameter_Direction direction;
@property (nonatomic, assign)short bradycardiaThreshold;
@property (nonatomic, assign)short tachycardiaThreshold;

+ (ECGParameter *)sharedECGParameter;

@end

/** PULMO ***/
@interface SpirometerParameter : NSObject

@property (nonatomic, assign)DeviceSettingOption_Gender gender;
@property (nonatomic, assign)NSInteger nAge;        // 6~100
@property (nonatomic, assign)NSInteger nHeight;     // 80~240
@property (nonatomic, assign)NSInteger nWeight;     // 15~250
@property (nonatomic, assign)Spirometer_Standard standard;
@property (nonatomic, assign)BOOL bSmoke;

+ (SpirometerParameter *)sharedSpirometerParameter;

@end

@interface SpirometerPredictedValue : NSObject

@property (nonatomic, assign)double FVC;
@property (nonatomic, assign)double FEV1;
@property (nonatomic, assign)double FEV1Pred;
@property (nonatomic, assign)double PEF;
@property (nonatomic, assign)double FEF2575;
@property (nonatomic, assign)double FEF25;
@property (nonatomic, assign)double FEF75;

@property (nonatomic, retain)NSString *strFVC;
@property (nonatomic, retain)NSString *strFEV1;
@property (nonatomic, retain)NSString *strFEV1Pred;
@property (nonatomic, retain)NSString *strPEF;
@property (nonatomic, retain)NSString *strFEF2575;
@property (nonatomic, retain)NSString *strFEF25;
@property (nonatomic, retain)NSString *strFEF75;

@end

/** BreathingTrainer ***/
@interface BreathingTrainerParameter : NSObject

@property (nonatomic, assign)BreathingTrainer_TrainMode mode;
@property (nonatomic, assign)float targetCapacity; //目标容量 [精确到小数点后两位，单位 L]
@property (nonatomic, assign)float targerFlow;     //目标流量 [精确到小数点后两位，单位 L/s]
@property (nonatomic, assign)unsigned char targetCount;     //目标次数 [1,30] (次)

+ (BreathingTrainerParameter *)sharedBreathingTrainerParameter;

@end


/** **********/

@protocol ContecBluetoothDelegate <NSObject>

@required

- (void)contec_getDeviceData:(NSDictionary *)dicDeviceData;

- (void)contec_getOperateResult:(NSDictionary *)dicOperateResult;

- (void)contec_getError:(NSDictionary *)dicError;

@optional

- (void)contec_receivedCaseDataProgress:(NSInteger)progress;

- (void)contec_receivedCaseIndex:(NSInteger)index progress:(float)progress;

- (void)contec_receivedCaseCount:(NSInteger)count;

- (void)contec_receivedRealtimeValueData:(NSDictionary *)valueDic;

- (void)contec_receivedRealtimeWaveData:(NSDictionary *)waveDic;

- (void)contec_receivedRealtimeRedLightData:(NSDictionary *)redLightDic;

- (void)contec_receivedGlucoseDeviceState:(GlucoseState)state;

- (void)contec_receivedPM10DataList:(NSArray *)dataList;

/** 仅在呼吸训练器获取实时数据时回调以下函数 */
- (void)contec_receivedBreathingTrainerTrainedWaveData:(NSDictionary *)waveDic;

- (void)contec_receivedBreathingTrainerTrainedSegmentResultData:(NSDictionary *)resultDic;

- (void)contec_receivedBreathingTrainerTrainedResultData:(NSDictionary *)resultDic;

- (void)contec_receivedBreathingTrainerTrainedImpedanceRating:(NSDictionary *)dic;
/** 仅在呼吸训练器获取实时数据时回调以上函数 */
/** SP90 定标 */
- (void)contec_receivedCalibrationInfomation:(NSDictionary *)info;

- (void)contec_receivedCalibrationResult:(NSDictionary *)result;
/** SP90 实时数据回调 */
- (void)contec_receivedSpirometerWaveData:(NSDictionary *)waveDic;

- (void)contec_SpirometerStoped:(BOOL)flag;

- (void)contec_receivedMeasureResult:(NSDictionary *)result;

@end

@interface ContecBluetoothSDK : NSObject

@property (nonatomic, weak) id<ContecBluetoothDelegate> delegate;

+ (ContecBluetoothSDK *)sharedSingleton;

- (NSString *)SDKVersion;

- (void)matchRangeID:(NSString *)rangeID forDeviceType:(DeviceType)type;
- (void)customizeBluetoothName:(NSString *)name forDeviceType:(DeviceType)type;

- (void)peripheral:(CBPeripheral *)peripheral receiveData:(ReceiveParameter)type;
- (void)peripheral:(CBPeripheral *)peripheral deleteData:(DeleteParameter)type;

/** 3.1.1 */
- (void)queryDeviceFirmwareVersionFromPeripheral:(CBPeripheral *)peripheral;
/** SpO2 */
- (void)queryDeviceStateInfoFromPeripheral:(CBPeripheral *)peripheral;
- (void)queryBatteryPowerFromPeripheral:(CBPeripheral *)peripheral;
- (void)queryTimeFromPeripheral:(CBPeripheral *)peripheral;
- (void)synchronizeTime:(NSDate *)date ToPeripheral:(CBPeripheral *)peripheral;
- (void)queryDataStateFromPeripheral:(CBPeripheral *)peripheral;
- (void)cancelConnectWithPeripheral:(CBPeripheral *)peripheral;
/** changed in 3.0.9 version*/
- (void)startReceiveRealtimeDataWithPeripheral:(CBPeripheral *)peripheral DEPRECATED_MSG_ATTRIBUTE("use peripheral:startReceiveRealtimeDataWithType: instead");
- (void)peripheral:(CBPeripheral *)peripheral startReceiveRealtimeDataWithType:(SpO2RealTimeDatatype)type;
- (void)endReceiveRealtimeDataWithPeripheral:(CBPeripheral *)peripheral;

/** ECG */
@property (nonatomic, assign)BOOL bSingleReceive;
- (void)getECGParameterFromPeripheral:(CBPeripheral *)peripheral;
- (void)peripheral:(CBPeripheral *)peripheral setECGParameter:(ECGParameter *)parameter;
- (void)keepConnection:(CBPeripheral *)peripheral;
- (void)peripheral:(CBPeripheral *)peripheral receiveDataListWithType:(ReceiveParameter)type;
- (void)peripheral:(CBPeripheral *)peripheral receiveDataWithBasicInfo:(NSDictionary *)basicInfo;
- (void)peripheral:(CBPeripheral *)peripheral deleteDataWithBasicInfo:(NSDictionary *)basicInfo;
- (void)autoReceiveECGCaseFromPeripheral:(CBPeripheral *)peripheral;

/** PULMO */
- (void)peripheral:(CBPeripheral *)peripheral setPULMOParameter:(SpirometerParameter *)parameter;
- (SpirometerPredictedValue *)calculatePredictedValueWithParameter:(SpirometerParameter *)parameter;

/** Glucose */
- (void)shutdownPeripheral:(CBPeripheral *)peripheral;

/** TEMP */
- (void)readyToReveiveDataFromThermometer:(CBPeripheral *)peripheral;

/** Breathing Trainer */
- (void)breathingTrainer:(CBPeripheral *)peripheral NotifyParameterToDevice:(BreathingTrainerParameter *)parameter;
- (void)breathingTrainerGetImpedanceRating:(CBPeripheral *)peripheral;
- (void)breathingTrainerStartTrain:(CBPeripheral *)peripheral;
- (void)breathingTrainerStopTrain:(CBPeripheral *)peripheral;

/** SP90 */
- (void)queryCalibrationCoefficients:(CBPeripheral *)peripheral;
// inhale:[0.5, 1.5]     exhale:[0.5, 1.5]
- (void)peripheral:(CBPeripheral *)peripheral syncCalibrationCoefficientsInhale:(float)inhale Exhale:(float)exhale;
- (void)queryTemperatureHumidityAtmosphericPressure:(CBPeripheral *)peripheral;
- (void)queryCaseCount:(CBPeripheral *)peripheral;
- (void)peripheral:(CBPeripheral *)peripheral set:(SP90DataType)type numberAndOrderOfParameterDisplay:(NSArray *)ary;
// caoacity [1,10]
- (void)peripheral:(CBPeripheral *)peripheral startCalibrationWithBarrelCapcity:(NSInteger)capacity;
- (void)cancelCalibration:(CBPeripheral *)peripheral;
- (void)peripheral:(CBPeripheral *)peripheral startMeasureWithType:(SP90DataType)type openBTPS:(BOOL)bBTPS;
- (void)peripheral:(CBPeripheral *)peripheral stopMeasureWithType:(SP90DataType)type;
@end

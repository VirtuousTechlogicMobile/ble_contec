//
//  DataType.h
//  ContecBluetoothSDK
//
//  Created by CONTEC01 on 2020/1/15.
//  Copyright © 2020 CONTEC01. All rights reserved.
//

#ifndef DataType_h
#define DataType_h

typedef enum : NSUInteger {
    DeviceType_BC401,
    DeviceType_PM10,
    DeviceType_Contec08A,
    DeviceType_Contec08C,
    DeviceType_CMS50D,
    DeviceType_CMS50F,
    DeviceType_CMS50IW,
    DeviceType_SP70B,
    DeviceType_SP80B,
    DeviceType_CMS50S,
    DeviceType_NPI009,
    DeviceType_CMS50E,
    DeviceType_SP70BEXP,
    DeviceType_SP80BEXP,
    DeviceType_Thermometer,
    DeviceType_CMS50K,
    DeviceType_SP10,
    DeviceType_CMS50K1,
    DeviceType_PM20,
    DeviceType_RT10,
    DeviceType_SP90,
} DeviceType;

typedef enum : NSUInteger {
    
    /** Urinalysis Device (BC401) */
    ReceiveParameter_Urinalysis_All,
    ReceiveParameter_Urinalysis_Last,
    ReceiveParameter_Urinalysis_All_Display,
    ReceiveParameter_Urinalysis_Last_Display,
    ReceiveParameter_Urinalysis_All_Subdivision,
    ReceiveParameter_Urinalysis_Last_Subdivision,
    ReceiveParameter_Urinalysis_All_Subdivision_Display,
    ReceiveParameter_Urinalysis_Last_Subdivision_Display,
    
    /** ECG Device (PM10/PM20) */
    ReceiveParameter_ECG_NotUploaded_Delete,
    ReceiveParameter_ECG_All_Delete,
    ReceiveParameter_ECG_NotUploaded_WithoutDelete,
    ReceiveParameter_ECG_All_WithoutDelete,
    ReceiveParameter_ECG_BasicInfo_All,
    ReceiveParameter_ECG_BasicInfo_NotUpload,
    ReceiveParameter_ECG_BasicInfo_Upload,
//    ReceiveParameter_ECG_BasicInfo_Designated,
    
    /** NIBP Device (CONTEC 08A/08C) */
    ReceiveParameter_NIBP_Delete,
    ReceiveParameter_NIBP_WithoutDelete,
    
    /** Blood Oxygen Device (50E/50D-bt/50IW/50S/50F)*/
    ReceiveParameter_SpO2_Delete,
    ReceiveParameter_SpO2_WithoutDelete,
    
    /** Spirometer (SP70B/SP80B/SP70BEXP/SP80BEXP/SP10) */
    ReceiveParameter_Spirometer_Delete,
    ReceiveParameter_Spirometer_WithoutDelete,
    
    ReceiveParameter_BloodGlucose,
    
    ReceiveParameter_CMS50K_Delete,
    ReceiveParameter_CMS50K_WithoutDelete,
    
    ReceiveParameter_Thermometer,
    
    ReceiveParameter_BreathingTrainer_Delete,
    ReceiveParameter_BreathingTrainer_WithoutDelete,
    
    ReceiveParameter_SP90_FVC_Delete,
    ReceiveParameter_SP90_FVC_WithoutDelete,
    ReceiveParameter_SP90_SVC_Delete,
    ReceiveParameter_SP90_SVC_WithoutDelete,
    ReceiveParameter_SP90_MVV_Delete,
    ReceiveParameter_SP90_MVV_WithoutDelete,
    ReceiveParameter_SP90_MV_Delete,
    ReceiveParameter_SP90_MV_WithoutDelete,
    
} ReceiveParameter;

typedef enum : NSUInteger {
    
    /** Urinalysis */
    DeleteParameter_Urinalysis,
    
    /** ECG */
    DeleteParameter_ECG,
    
    /** NIBP */
    
    /** Blood Oxygen Device  */
    DeleteParameter_SpO2,
    
    DeleteParameter_BloodGlucose,
    
    DeleteParameter_CMS50K,
    
    /** Spirometer */
    DeleteParameter_Spirometer,
    
    /** RT01 BreathingTrainer */
    DeleteParameter_BreathingTrainer,
    
} DeleteParameter;
/*
 DataType_CMS50F_Receive_Delete,
 DataType_CMS50F_Receive_WithoutDelete,
 DataType_CMS50F_Delete,
 */

typedef enum : NSUInteger {
    ECGParameter_Language_Chinese,
    ECGParameter_Language_English,
    ECGParameter_Language_Italian,
    ECGParameter_Language_Russian,
    ECGParameter_Language_French,
    ECGParameter_Language_Bulgarian,
    ECGParameter_Language_Kazakh,
    ECGParameter_Language_Polish,
    ECGParameter_Language_Ukrainian,
    ECGParameter_Language_Spanish,
    ECGParameter_Language_Slovak,
    ECGParameter_Language_Portuguese,
    ECGParameter_Language_Turkish,
    ECGParameter_Language_German,
    ECGParameter_Language_Japanese,
    ECGParameter_Language_Hindi,
    ECGParameter_Language_Arabic,
    ECGParameter_Language_Dutch,
} ECGParameter_Language;

typedef enum : NSUInteger {
    ECGParameter_SaveTime_10s,
    ECGParameter_SaveTime_15s,
    ECGParameter_SaveTime_30s,
} ECGParameter_SaveTime;

typedef enum : NSUInteger {
    ECGParameter_HearRateVoice_on,
    ECGParameter_HearRateVoice_off,
} ECGParameter_HearRateVoice;

typedef enum : NSUInteger {
    ECGParameter_ShieldAnalysis_on,
    ECGParameter_ShieldAnalysis_off,
} ECGParameter_ShieldAnalysis;

typedef enum : NSUInteger {
    ECGParameter_Direction_Portrait,
    ECGParameter_Direction_LandscapeRight,
    ECGParameter_Direction_LandscapeLeft,
} ECGParameter_Direction;

typedef enum : NSUInteger {
    DeviceSettingOption_Gender_Male,
    DeviceSettingOption_Gender_Female,
} DeviceSettingOption_Gender;

typedef enum : NSUInteger {
    Spirometer_Standard_ERS = 1,
    Spirometer_Standard_KNUDSON,
    Spirometer_Standard_USA,
} Spirometer_Standard;

typedef enum : NSUInteger {
    GlucoseState_BloodDrop,
    GlucoseState_StartMeasuring,
    GlucoseState_ShutDown,
    GlucoseState_DataError_E1,
    GlucoseState_DataError_E2,
    GlucoseState_DataError_E3,
    GlucoseState_DataError_E6,
    GlucoseState_DataError_E7,
    GlucoseState_DataError_HI,
    GlucoseState_DataError_LO,
} GlucoseState;

typedef NS_OPTIONS(NSUInteger, SpO2RealTimeDatatype) {
    SpO2RealTimeDatatype_Value = 1 << 0,
    SpO2RealTimeDatatype_Wave = 1 << 1,
    SpO2RealTimeDatatype_RedLight = 1 << 2,
};

typedef enum : NSUInteger {
    BreathingTrainer_TrainMode_Inhale = 0x01, //吸气
    BreathingTrainer_TrainMode_Exhale,        //呼气
} BreathingTrainer_TrainMode;

typedef enum : Byte {
    SP90CommandType_Start = 0x00,
    SP90CommandType_Continue,
    SP90CommandType_Resend,
    SP90CommandType_Stop_unDelete = 0x7d,
    SP90CommandType_end_unDelete,
    SP90CommandType_end_Delete,
} SP90CommandType;

typedef enum : Byte {
    SP90DataType_FVC = 0x01,
    SP90DataType_SVC,
    SP90DataType_MVV,
    SP90DataType_MV
} SP90DataType;

#endif /* DataType_h */

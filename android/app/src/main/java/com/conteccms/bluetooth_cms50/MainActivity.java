package com.conteccms.bluetooth_cms50;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.contec.cms50s.code.bean.ResultData;
import com.contec.cms50s.code.callback.BluetoothSearchCallback;
import com.contec.cms50s.code.callback.CommunicateCallback;
import com.contec.cms50s.code.callback.DeleteDataCallback;
import com.contec.cms50s.code.callback.DeviceStateCallback;
import com.contec.cms50s.code.callback.GetDeviceBatteryCallback;
import com.contec.cms50s.code.callback.GetDeviceTimeCallback;
import com.contec.cms50s.code.callback.GetFirmwareVersionCallback;
import com.contec.cms50s.code.callback.QueryDataStatusCallback;
import com.contec.cms50s.code.callback.RealtimeCallback;
import com.contec.cms50s.code.callback.SetDeviceTimeCallback;
import com.contec.cms50s.code.connect.ContecSdk;
import com.contec.cms50s.code.tools.Utils;
import com.google.firebase.Firebase;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.crashlytics.FirebaseCrashlytics;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.contectcms.bluetooth_cms5";
    private static final String TAG = "MainActivity";
    private BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    BluetoothDevice mDevice;
    private StringBuffer stringBuffer;
    ContecSdk sdk;
    String mFoundDeviceInfo;
    private boolean permissionOk = false, isConnected = false;
    private final int REQUEST_ENABLE_BT = 1;
    private final int REQUEST_FINE_LOCATION = 0;
    private final int REQUEST_COR_LOCATION = 0;
    private final int REQUEST_BL = 0;
    private final int REQUEST_STORAGE = 0;
    private final int REQUEST_ALL_PERMISSION = 0;

    private FirebaseAnalytics mFirebaseAnalytics;
    private FirebaseCrashlytics mFirebaseCrashlytics;

    public EventChannel.EventSink eventChannel;
    public static final String STREAM = "getRealTimeDataEventChannel";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            mFirebaseAnalytics = FirebaseAnalytics.getInstance(MainActivity.this);
                            mFirebaseCrashlytics = FirebaseCrashlytics.getInstance();
                            ActivityCompat.requestPermissions(MainActivity.this,
                                    new String[]{Manifest.permission.ACCESS_COARSE_LOCATION,
                                            Manifest.permission.ACCESS_FINE_LOCATION,
                                            Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                            Manifest.permission.BLUETOOTH_CONNECT,
                                            Manifest.permission.BLUETOOTH_SCAN}
                                    , REQUEST_ALL_PERMISSION);
                            if (call.method.toString().equals("startRealtimeData")) {
                                result.success("ok");
                                new EventChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor(), STREAM).setStreamHandler(
                                        new EventChannel.StreamHandler() {
                                            @Override
                                            public void onListen(Object args, final EventChannel.EventSink events) {
                                                eventChannel = events;
                                                manageStartRealTimeData(result, eventChannel);
                                            }

                                            @Override
                                            public void onCancel(Object args) {
                                                eventChannel = null;
                                                System.out.println("StreamHandler - onCanceled: ");
                                            }
                                        }
                                );
                            } else {
                                callMethodAndGetData(call.method, result);
                            }

                        }
                );
    }

    private void manageStartRealTimeData(MethodChannel.Result result, EventChannel.EventSink eventChannel) {
        new Thread() {
            @Override
            public void run() {
                sdk.startRealtime(new RealtimeCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                    }

                    @Override
                    public void onRealtimeWaveData(final int signal,
                                                   int prSound,
                                                   final int waveData, final int barData, int fingerOut) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Log.e(TAG, "signal：" + signal);
                                        Log.e(TAG, "barData：" + barData);
                                        Log.e(TAG, "waveData：" + waveData);
                                        Log.e(TAG, "fingerOut：" + fingerOut);
//                                        String realTimeDataString = "signal：" + signal + " barData：" + barData + " waveData： " + waveData + " fingerOut: " + fingerOut;
//                                        eventChannel.success(realTimeDataString);
                                    }
                                });
                            }
                        });

                    }

                    @Override
                    public void onSpo2Data(final int piError, final int spo2, final int pr, final int pi) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Log.e(TAG, "piError = " + piError + "  spo2: " + spo2 + "  pr: " + pr + "  PI: " + pi);
                                        String realTimeDataString = "piError= " + piError + "\nspo2: " + spo2 + "pr: " + pr + "\nPI: " + pi;
                                        eventChannel.success(realTimeDataString);
                                    }
                                });
                            }
                        });
                    }

                    @Override
                    public void onRealtimeEnd() {
                        runOnUiThread(() -> {
                            Log.e("TAG", "real time end");
                            addFirebaseLog("onRealtimeEnd", "Real Time End");
                            //result.success("Real Time End");
                        });
                    }
                });
            }
        }.start();
    }


    public void addFirebaseLog(String methodName, String data) {
        Bundle bundle = new Bundle();
        bundle.putString("Method Name_Button Click : ", methodName);
        bundle.putString("Result :", data);
        mFirebaseAnalytics.logEvent(methodName, bundle);
        Log.e(TAG, "addFirebaseLog: LOG ADDED SUCCESSFULLY");
    }

    public void addFirebaseCrash(String exception) {
        mFirebaseCrashlytics.setCrashlyticsCollectionEnabled(true);
        mFirebaseCrashlytics.log(exception);
        Log.e(TAG, "addFirebaseLog: LOG ADDED SUCCESSFULLY");
    }

    void checkPermission(MethodChannel.Result result) {
        if (mBluetoothAdapter == null) {
            Toast.makeText(this, "this is not support bluetooth", Toast.LENGTH_LONG).show();
        } else if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(
                    BluetoothAdapter.ACTION_REQUEST_ENABLE);
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    ActivityCompat.requestPermissions(MainActivity.this,
                            new String[]{Manifest.permission.BLUETOOTH_CONNECT}
                            , REQUEST_BL);
                }
            }
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        } else {
            permissionOk = true;
            addFirebaseLog("checkPermission", result.toString());
            result.success("All permissions are granted");
        }
        //        if (ActivityCompat.checkSelfPermission(MainActivity.this,
//                Manifest.permission.ACCESS_COARSE_LOCATION)
//                != PackageManager.PERMISSION_GRANTED) {
//            ActivityCompat.requestPermissions(MainActivity.this,
//                    new String[]{Manifest.permission.ACCESS_COARSE_LOCATION}
//                    , REQUEST_COR_LOCATION);
//        } else
//        if (ActivityCompat.checkSelfPermission(MainActivity.this,
//                Manifest.permission.ACCESS_FINE_LOCATION)
//                != PackageManager.PERMISSION_GRANTED) {
//            ActivityCompat.requestPermissions(MainActivity.this,
//                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION}
//                    , REQUEST_FINE_LOCATION);
//        } else if (ActivityCompat.checkSelfPermission(MainActivity.this,
//                Manifest.permission.WRITE_EXTERNAL_STORAGE)
//                != PackageManager.PERMISSION_GRANTED) {
//            ActivityCompat.requestPermissions(MainActivity.this,
//                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}
//                    , REQUEST_STORAGE);
//        } else if (ActivityCompat.checkSelfPermission(MainActivity.this,
//                Manifest.permission.BLUETOOTH_CONNECT)
//                != PackageManager.PERMISSION_GRANTED) {
//            ActivityCompat.requestPermissions(MainActivity.this,
//                    new String[]{Manifest.permission.BLUETOOTH_CONNECT}
//                    , REQUEST_BL);
//        } else {
//            if (mBluetoothAdapter == null) {
//                Toast.makeText(this, "this is not support bluetooth", Toast.LENGTH_LONG).show();
//            } else if (!mBluetoothAdapter.isEnabled()) {
//                Intent enableBtIntent = new Intent(
//                        BluetoothAdapter.ACTION_REQUEST_ENABLE);
//                startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
//            } else {
//                permissionOk = true;
//                addFirebaseLog("checkPermission", result.toString());
//                result.success("All permissions are granted");
//            }
//        }

    }

    private void callMethodAndGetData(String method, MethodChannel.Result result) {
        switch (method) {
            case "checkPermissions":
                checkPermission(result);
                break;
            case "startSearch":
                permissionOk = true;
//                checkBluetoothOnOrNot(result);
                if (permissionOk) {
                    mFoundDeviceInfo = null;
                    mDevice = null;
                    bluetoothResultSearch(result);
                } else {
                    Toast.makeText(this, "Please grant all permissions", Toast.LENGTH_SHORT).show();
                }
                break;
            case "stopSearch":
                sdk.stopBluetoothSearch();
                addFirebaseLog("stopSearch", result.toString());
                result.success("stopSearchExecuted");
                break;
            case "connectDevice":
//                sdk.stopBluetoothSearch();
                connectDevice(result);
                break;
            case "disconnectDevice":
                sdk.disconnect();
                addFirebaseLog("disconnectDevice", result.toString());
                result.success("Disconnect Device");
                break;
            case "getDeviceState":
                sdk.queryDeviceState(new DeviceStateCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "errorCode = " + errorCode);
                            addFirebaseLog("queryDeviceState", "Error Code : " + errorCode);
                            result.success("Device State Failed");
                        });
                    }

                    @Override
                    public void onDeviceStatus(final int storage, final int battery, final int probe, final int charge) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "storage = " + storage);
                            Log.e(TAG, "battery = " + battery);
                            Log.e(TAG, "probe   = " + probe);
                            Log.e(TAG, "charge = " + charge);
                            addFirebaseLog("queryDeviceState Data : ", "storage = " + storage + "  battery = " + battery +
                                    "  probe   = " + probe + "  charge = " + charge);
                            result.success("storage = " + storage + "  battery = " + battery +
                                    "  probe   = " + probe + "  charge = " + charge);
                        });
                    }
                });
                break;
            case "getBattery":
                sdk.getDeviceBattery(new GetDeviceBatteryCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "errorCode = " + errorCode);
                            addFirebaseLog("getDeviceBattery", "Error Code : " + errorCode);
                            result.success("Get Battery Failed");
                        });
                    }

                    @Override
                    public void onSuccess(final int battery) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "battery = " + battery);
                            addFirebaseLog("getDeviceBattery", "Battery % is  " + battery);
                            result.success("Battery % is " + battery);
                        });

                    }
                });
                break;
            case "getTime":
                sdk.getDeviceTime(new GetDeviceTimeCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "errorCode = " + errorCode);
                            addFirebaseLog("getDeviceTime", "Error Code : " + errorCode);
                            result.success("get Time Failed");
                        });

                    }

                    @Override
                    public void onSuccess(final String time) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "device time = " + time);
                            addFirebaseLog("getDeviceTime", "device time =" + time);
                            result.success("Time : " + time);
                        });
                    }
                });
                break;
            case "setTime":
                sdk.setDeviceTime(new SetDeviceTimeCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "errorCode = " + errorCode);
                            addFirebaseLog("setDeviceTime", "Error Code : " + errorCode);
                            result.success("Set Time Failed");
                        });
                    }

                    @Override
                    public void onSuccess(final int code) {
                        runOnUiThread(() -> {
                            if (code == 0) {
                                Log.e("TAG", "set time success");
                                addFirebaseLog("getDeviceTime", "set time success");
                                result.success("Time set successfully");
                            } else if (code == 1) {
                                Log.e("TAG", "set time fail");
                                addFirebaseLog("getDeviceTime", "set time fail");
                                result.success("Time set failed");
                            }
                        });
                    }
                });
                break;
            case "getFirmWareVersion":
                sdk.getFirmwareVersion(new GetFirmwareVersionCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        Log.e(TAG, "errorCode = " + errorCode);
                        runOnUiThread(() -> {
                            addFirebaseLog("getFirmWareVersion", "errorCode = " + errorCode);
                            result.success("Firmware version Failed");
                        });
                    }

                    @Override
                    public void onSuccess(final String version) {
                        Log.e(TAG, "version = " + version);
                        runOnUiThread(() -> {
                            addFirebaseLog("getFirmWareVersion", "Firmware version :" + version);
                            result.success("Firmware version :" + version);
                        });
                    }
                });
                break;
            case "getSDKVersion":
                sdk.getSdkVersion(sdkVersion -> runOnUiThread(() -> {
                    Log.e(TAG, "sdkVersion = " + sdkVersion);
                    addFirebaseLog("getSdkVersion", "sdkVersion version :" + sdkVersion);
                    result.success("SDK Version :" + sdkVersion);
                }));
                break;
            case "getDataStatus":
                sdk.queryDataStatus(new QueryDataStatusCallback() {
                    @Override
                    public void onFail(final int errorCode) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "errorCode = " + errorCode);
                            addFirebaseLog("getDataStatus", "errorCode = " + errorCode);
                            result.success("Data Status Failed");
                        });
                    }

                    @Override
                    public void onSuccess(final int staus) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "data status = " + staus);
                            addFirebaseLog("getDataStatus ", "Data Status : " + staus);
                            result.success("Data Status : " + staus);
                        });
                    }
                });
                break;
            case "cancelDisconnect":
                sdk.cancelConnect(errorCode -> runOnUiThread(() -> {
                    Log.e(TAG, "errorCode = " + errorCode);
                    addFirebaseLog("cancelConnect", "errorCode = " + errorCode);
                    result.success("Cancel Disconnect Failed");
                }));
                break;
            case "deleteData":
                sdk.deleteData(new DeleteDataCallback() {
                    @Override
                    public void onSuccess(final int status) {
                        runOnUiThread(() -> {
                            Log.e(TAG, "status = " + status);
                            addFirebaseLog("deleteData ", "deleteData Status : " + status);
                            result.success("Data Deleted Successfully " + status);
                        });
                    }

                    @Override
                    public void onFail(int errorCode) {
                        addFirebaseLog("deleteData", "Failed = " + errorCode);
                        result.success("Delete Data Failed");

                    }
                });
                break;
            case "sync":
                syncCommunicate(result);
                break;
//            case "startRealtimeData":
//                new Thread() {
//                    @Override
//                    public void run() {
//                        sdk.startRealtime(new RealtimeCallback() {
//                            @Override
//                            public void onFail(final int errorCode) {
//
//                            }
//
//                            @Override
//                            public void onRealtimeWaveData(final int signal,
//                                                           int prSound,
//                                                           final int waveData, final int barData, int fingerOut) {
//                                runOnUiThread(new Runnable() {
//                                    @Override
//                                    public void run() {
//                                        runOnUiThread(new Runnable() {
//                                            @Override
//                                            public void run() {
//                                                Log.e(TAG, "signal：" + signal);
//                                                Log.e(TAG, "barData：" + barData);
//                                                Log.e(TAG, "waveData：" + waveData);
//                                                Log.e(TAG, "fingerOut：" + fingerOut);
//                                                addFirebaseLog("startRealtimeData : onRealtimeWaveData", "signal：" + signal + " barData：" + barData + " waveData： " + waveData);
//                                                String realTimeDataString = "signal：" + signal + " barData：" + barData + " waveData： " + waveData + " fingerOut: " + fingerOut;
//                                                result.success(realTimeDataString);
////                                                eventChannel.setStreamHandler(new RealTimeDataHandler(realTimeDataString));
//                                            }
//                                        });
//                                    }
//                                });
//                            }
//
//                            @Override
//                            public void onSpo2Data(final int piError, final int spo2, final int pr, final int pi) {
//                                runOnUiThread(() -> {
//                                    Log.e(TAG, "piError = " + piError + "  spo2: " + spo2 + "  pr: " + pr + "  PI: " + pi);
//                                    addFirebaseLog("startRealtimeData : onSpo2Data", "piError= " + piError + "\nspo2: " + spo2 + "pr: " + pr + "\nPI: " + pi);
////                                    result.success("piError= " + piError + "\nspo2: " + spo2 + "pr: " + pr + "\nPI: " + pi);
//                                    String realTimeDataString = "piError= " + piError + "\nspo2: " + spo2 + "pr: " + pr + "\nPI: " + pi;
//                                    eventChannel.setStreamHandler(new RealTimeDataHandler(realTimeDataString));
//                                });
//                            }
//
//                            @Override
//                            public void onRealtimeEnd() {
//                                runOnUiThread(() -> {
//                                    Log.e("TAG", "real time end");
//                                    addFirebaseLog("onRealtimeEnd", "Real Time End");
//                                    result.success("Real Time End");
//                                });
//                            }
//                        });
//                    }
//                }.start();
//                break;
            case "stopRealtimeData":
                sdk.stopRealtime();
                addFirebaseLog("stopRealtimeData", "stopRealtimeData");
                result.success("Realtime Recording Stopped");
                break;
            default:
                Log.e(TAG, "callMethodAndGetData: Not Implemented");
                addFirebaseLog("callMethodAndGetData: Not Implemented", "Default Executed");
                result.notImplemented();

        }
    }


    private void syncCommunicate(MethodChannel.Result result) {
        sdk.communicate(new CommunicateCallback() {
            @Override
            public void onFail(final int errorCode) {

                runOnUiThread(() -> {
                    Log.e(TAG, "errorCode = " + errorCode);
                    addFirebaseLog("syncCommunicate", "errorCode = " + errorCode);
                    result.success("Sync Communication Failed");
                });
            }

            @Override
            public void onSuccess(final ResultData data) {

                stringBuffer = new StringBuffer();

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null != data) {
                            Log.e(TAG, "checkCode = " + data.getCheckCode());
                            Log.e(TAG, "length = " + data.getLength());
                            Log.e(TAG, "startTime = " + data.getStartTime());
                            stringBuffer.append("checkCode = " + data.getCheckCode() + "\n");
                            stringBuffer.append("length = " + data.getLength() + "\n");
                            stringBuffer.append("startTime = " + data.getStartTime() + "\n");

                            //将数据存入文件中
                            FileOutputStream fOut = null;
                            String case_path = Environment.getExternalStorageDirectory() + "/SpO250S";
                            File file = new File(case_path);
                            if (!file.exists()) {
                                file.mkdirs();
                            }

                            File mFile = new File(case_path + "/" + "SpO2.dat");
                            try {
                                fOut = new FileOutputStream(mFile);
                            } catch (
                                    FileNotFoundException e) {
                                e.printStackTrace();
                            }

                            for (int j = 0; j < data.getLength(); j++) {
                                try {
                                    fOut.write(toBytes(data.getSpo2Data()[j]));
                                    fOut.write(toBytes(data.getPrData()[j]));

                                    //fOut.write(toBytes(data.getPieceData().getPrData()[i]));
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                          /*      Log.e(TAG, "SpO2 = " + data.getSpo2Data()[j]);
                                stringBuffer.append("SpO2 = " + data.getSpo2Data()[j] + "     ");
                                Log.e(TAG, "pr = " + data.getPrData()[j]);
                                stringBuffer.append("pr = " + data.getPrData()[j] + "\n");*/
                            }
                            addFirebaseLog("syncCommunicate", "SUCCESS = " + stringBuffer.toString());
                            result.success(stringBuffer);
                        } else {
                            addFirebaseLog("syncCommunicate", "data length different");
                            result.success("data length different");
                        }
                    }
                });
            }
        });
    }

    private byte[] toBytes(int spo2) {
        return new byte[]{(byte) (spo2 & 0xFF),
                (byte) ((spo2 >> 8) & 0xFF)};
    }

    private void connectDevice(MethodChannel.Result result) {
        if (ActivityCompat.checkSelfPermission(this,
                android.Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            checkPermission(result);
        } else {
            if (mDevice != null && !TextUtils.isEmpty(mDevice.getName()) &&
                    mDevice.getName().contains("SpO211")) {
//
                sdk.connect(mDevice, status -> {
                    Log.e(TAG, "connectStatus = " + status);
                    if (status == ContecSdk.NOTIFY_SUCCESS) {
                        //监听成功
                        isConnected = true;
                    }
                    if (status == ContecSdk.STATE_DISCONNECTED || status == ContecSdk.STATE_ABNORMAL_DISCONNECTED
                            || status == ContecSdk.STATE_CANCEL_CONNECT) {
                        isConnected = false;
                    }
                });
                addFirebaseLog("connectDevice", mDevice.getName());
                result.success("Device Connected Successfully");
            } else {
                Log.e(TAG, "this is not 50s device");
                addFirebaseLog("connectDevice", "this is not 50s device " + " : " + mFoundDeviceInfo + " : " + mDevice);
                result.success("this is not 50s device " + "" + mFoundDeviceInfo + "" + mDevice);
            }
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        sdk = new ContecSdk(getApplicationContext());
        permissionOk = false;

    }

    byte[] getManufacturerSpecificData(byte[] bytes) {

        byte[] msd = null;
        for (int i = 0; i < bytes.length - 1; ++i) {
            byte len = bytes[i];
            byte type = bytes[i + 1];

            if ((byte) 0xFF == type) {
                msd = new byte[len - 1];

                for (int j = 0; j < len - 1; ++j) {
                    msd[j] = bytes[i + j + 2];
                }
                return msd;
            } else {
                i += len;
            }
        }

        return msd;
    }

    private void bluetoothResultSearch(MethodChannel.Result result) {
        sdk.startBluetoothSearch(new BluetoothSearchCallback() {
            @Override
            public void onDeviceFound(final BluetoothDevice device, int rssi, final byte[] record) {
                Log.e(TAG, "BYTE = " + Utils.bytesToHexString(record));
                runOnUiThread(() -> {
                    if (ActivityCompat.checkSelfPermission(MainActivity.this, android.Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                        checkPermission(result);
                    } else {
                        Log.e(TAG, "search device = " + device.getName());
                        String manufactorSpecificString = null;
                        if (record != null) {
                            byte[] manufactorSpecificBytes = getManufacturerSpecificData(record);
                            if (manufactorSpecificBytes != null) {
                                manufactorSpecificString = new String(manufactorSpecificBytes);
                            }
                        }
                        StringBuffer stringBuffer = new StringBuffer();
                        stringBuffer.append(device.getName()).append(" ");
                        if (manufactorSpecificString != null) {
                            if (manufactorSpecificString.contains("DT")) {
                                int index = manufactorSpecificString.indexOf("DT");
                                String date = manufactorSpecificString.substring(index + 2, index + 8);
                                if (manufactorSpecificString.contains("DATA")) {
                                    stringBuffer.append(manufactorSpecificString).append("  has data, current date:").append(date);
                                } else {
                                    stringBuffer.append(manufactorSpecificString).append("  has no data,current date:").append(date);
                                }
                            } else if (manufactorSpecificString.contains("DATA")) {
                                stringBuffer.append(manufactorSpecificString).append("  has data but no time");
                            }
                        }
                        Log.e(TAG, "mFoundDeviceInfo : " + mFoundDeviceInfo);
                        Log.e(TAG, "mDevice : " + mDevice);
                        if (device.getName().contains("SpO211")) {
                            mDevice = device;
                            mFoundDeviceInfo = stringBuffer.toString();
                            sdk.stopBluetoothSearch();
                        }
//                        Log.e(TAG, "run: " + stringBuffer);
//                        mDevice = device;
//                        mFoundDeviceInfo = stringBuffer.toString();
//                        sdk.stopBluetoothSearch();
//                        Log.e(TAG, "mFoundDeviceInfo : " + mFoundDeviceInfo);
//                        Log.e(TAG, "mDevice : " + mDevice);
                    }
                });
                addFirebaseLog("bluetoothResultSearch", result.toString() + " FoundDeviceInfo :" + mFoundDeviceInfo + " Device : " + mDevice);
//                result.success(mFoundDeviceInfo);

            }

            @Override
            public void onSearchError(int errorCode) {
                if (errorCode == ContecSdk.NO_BLUETOOTH) {
                    Log.e(TAG, "this no bluetooth");
                    addFirebaseLog("onSearchError", "this no bluetooth : " + errorCode);
                    result.success("this no bluetooth");
                } else if (errorCode == ContecSdk.BLUETOOTH_CLOSE) {
                    Log.e(TAG, "bluetooth not enable");
                    addFirebaseLog("onSearchError", "bluetooth not enable : " + errorCode);
                    result.success("bluetooth not enable");
                }
            }

            @Override
            public void onSearchComplete() {
                runOnUiThread(() -> {
                    Log.e(TAG, "search complete");
                    if (mDevice != null) {
                        String text = "search complete,found device:" + mFoundDeviceInfo;
//                        addFirebaseLog("onSearchComplete", "search complete,found device:" + mFoundDeviceInfo);
                        result.success(text);
                    } else {
                        addFirebaseLog("onSearchComplete", "search complete,no device.");
                        result.success("search complete,no device.");
                    }

                });
            }
        }, 20000);


    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case REQUEST_ENABLE_BT:
                if (resultCode == RESULT_OK) {
                    permissionOk = true;
                } else if (resultCode == RESULT_CANCELED) {
                    Toast.makeText(this, "bluetooth closed", Toast.LENGTH_SHORT).show();
                }
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case REQUEST_ALL_PERMISSION:
                if (mBluetoothAdapter == null) {
                    Toast.makeText(this, "this is not support bluetooth", Toast.LENGTH_LONG).show();
                } else if (!mBluetoothAdapter.isEnabled()) {

                    //启动蓝牙
                    Intent enableBtIntent = new Intent(
                            BluetoothAdapter.ACTION_REQUEST_ENABLE);
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                        Toast.makeText(this, "Enable your bluetooth first", Toast.LENGTH_LONG).show();

                    } else
                        startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
                } else {
                    permissionOk = true;
                }

                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}

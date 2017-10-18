package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

// For MDM
import android.content.RestrictionsManager;
import android.app.ActivityManager;
import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableNativeMap;
import java.util.Map;
import java.util.HashMap;
import javax.annotation.Nullable;

public class RNMobileDeviceManagerModule extends ReactContextBaseJavaModule {
    public static final String MODULE_NAME = "MobileDeviceManager";
    public static final String APP_CONFIG_CHANGED = "react-native-mdm/managedAppConfigDidChange";

    public RNMobileDeviceManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        final ReactApplicationContext thisContext = reactContext;

        final RestrictionsManager restrictionsManager = (RestrictionsManager) reactContext.getSystemService(Context.RESTRICTIONS_SERVICE);

        IntentFilter restrictionFilter = new IntentFilter(Intent.ACTION_APPLICATION_RESTRICTIONS_CHANGED);
        BroadcastReceiver restrictionReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Bundle appRestrictions = restrictionsManager.getApplicationRestrictions();
                WritableNativeMap data = new WritableNativeMap();
                for (String key : appRestrictions.keySet()){
                    data.putString(key, appRestrictions.getString(key));
                }
                if (thisContext.hasActiveCatalystInstance()) {
                    thisContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(APP_CONFIG_CHANGED, data);
                }
            }
        };
        thisContext.registerReceiver(restrictionReceiver,restrictionFilter);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void enableLockState() {
      if (!isLockState()) {
        startLockTask();
      }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void disableLockState() {
      if (isLockState()){
        try {
          stopLockTask();
        } catch (SecurityException e) {

        }
      }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public void isLockStatePermitted() {
      DevicePolicyManager dpm = (DevicePolicyManager)
      getReactApplicationContext().getSystemService(Context.DEVICE_POLICY_SERVICE);
      return dpm.isLockTaskPermitted(this.getPackageName());
    }

    @TargetApi(Build.VERSION_CODES.M)
    public boolean isLockState() {
      boolean isLocked = false;
      ActivityManager am = (ActivityManager) getReactApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
      try {
        if (am.getLockTaskModeState() !== ActivityManager.LOCK_TASK_MODE_NONE) {
          isLocked = true;
        }
      } catch (Exception e) {

      }
      return isLocked;
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }

    @Override
    public @Nullable Map<String, Object> getConstants() {
        HashMap<String, Object> constants = new HashMap<String, Object>();
        constants.put("APP_CONFIG_CHANGED", APP_CONFIG_CHANGED);
        return constants;
    }

    private boolean isMDMSupported() {
        RestrictionsManager restrictionsManager = (RestrictionsManager) super.getReactApplicationContext().getSystemService(Context.RESTRICTIONS_SERVICE);
        return restrictionsManager.getApplicationRestrictions().size() > 0;
    }

    @ReactMethod
    public void isSupported(final Promise promise) {
        promise.resolve(isMDMSupported());
    }

    @ReactMethod
    public void getConfiguration(final Promise promise) {
        if (isMDMSupported()) {
            RestrictionsManager restrictionsManager = (RestrictionsManager) super.getReactApplicationContext().getSystemService(Context.RESTRICTIONS_SERVICE);
            Bundle appRestrictions = restrictionsManager.getApplicationRestrictions();
            WritableNativeMap data = new WritableNativeMap();
            for (String key : appRestrictions.keySet()){
                data.putString(key, appRestrictions.getString(key));
            }
            promise.resolve(data);
        } else {
          promise.reject(new Error("Managed App Config is not supported"));
        }
    }

    @ReactMethod
    public void isAutonomousSingleAppModeSupported(final Promise promise) {
      promise.resolve(isLockStatePermitted());
    }

    @ReactMethod
    public void isAutonomousSingleAppModeEnabled(final Promise promise) {
      promise.resolve(isLockState());
    }

    @ReactMethod
    public void enableAutonomousSingleAppMode(final Promise promise) {
      promise.resolve(enableLockState());
    }

    @ReactMethod
    public void disableAutonomousSingleAppMode(final Promise promise) {
      promise.resolve(disableLockState());
    }
}

package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

// For MDM
import android.app.Activity;
import android.content.RestrictionsManager;
import android.app.ActivityManager;
import android.app.admin.DevicePolicyManager;
import android.os.Bundle;
import android.os.Build;
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

    public boolean enableLockState() {
        if (!isLockState()) {
            Activity activity = getCurrentActivity();
            if (activity == null) {
                return false;
            }
            activity.startLockTask();
            return true;
        }
        return false;
    }

    public boolean disableLockState() {
        if (isLockState()) {
            Activity activity = getCurrentActivity();
            if (activity == null) {
                return false;
            }
            activity.stopLockTask();
            return true;
        }
        return false;
    }

    public boolean isLockStatePermitted() {
        DevicePolicyManager dpm = (DevicePolicyManager)
                getReactApplicationContext().getSystemService(Context.DEVICE_POLICY_SERVICE);
        return dpm.isLockTaskPermitted(getReactApplicationContext().getPackageName());
    }

    public boolean isLockState() {
        ActivityManager am = (ActivityManager) getReactApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return am.getLockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE;
        } else {
            return am.isInLockTaskMode();
        }
    }

    public boolean isASAM() {
        ActivityManager am = (ActivityManager) getReactApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return am.getLockTaskModeState() == ActivityManager.LOCK_TASK_MODE_LOCKED;
        } else {
            return isLockStatePermitted() && am.isInLockTaskMode();
        }
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
        RestrictionsManager restrictionsManager = (RestrictionsManager) getReactApplicationContext().getSystemService(Context.RESTRICTIONS_SERVICE);
        return restrictionsManager.getApplicationRestrictions().size() > 0;
    }

    @ReactMethod
    public void isSupported(final Promise promise) {
        promise.resolve(isMDMSupported());
    }

    @ReactMethod
    public void getConfiguration(final Promise promise) {
        if (isMDMSupported()) {
            RestrictionsManager restrictionsManager = (RestrictionsManager) getReactApplicationContext().getSystemService(Context.RESTRICTIONS_SERVICE);
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
    public void isSingleAppModeEnabled(final Promise promise) {
        try {
          promise.resolve(isLockState());
        } catch (Exception e) {
          promise.reject(e);
        }
    }

    @ReactMethod
    public void isAutonomousSingleAppModeEnabled(final Promise promise) {
        try {
          promise.resolve(isASAM());
        } catch (Exception e) {
          promise.reject(e);
        }
    }

    @ReactMethod
    public void enableAutonomousSingleAppMode(final Promise promise) {
        try {
            boolean locked = enableLockState();
            if (locked) {
              promise.resolve(locked);
            } else {
              promise.reject(new Error("Unable to enable ASAM"));
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void disableAutonomousSingleAppMode(final Promise promise) {
        try {
            boolean unlocked = disableLockState();
            if (unlocked) {
              promise.resolve(unlocked);
            } else {
              promise.reject(new Error("Unable to disable ASAM"));
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}

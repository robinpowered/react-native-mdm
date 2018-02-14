package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

// For MDM
import android.app.Activity;
import android.app.admin.DeviceAdminReceiver;
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
    public static final String APP_LOCK_STATUS_CHANGED = "react-native-mdm/appLockStatusDidChange";
    public static final String APP_LOCKED = "react-native-mdm/appLocked";

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

        IntentFilter appLockFilter = new IntentFilter();
        appLockFilter.addAction(DeviceAdminReceiver.ACTION_LOCK_TASK_ENTERING);
        appLockFilter.addAction(DeviceAdminReceiver.ACTION_LOCK_TASK_EXITING);
        BroadcastReceiver appLockReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                WritableNativeMap data = new WritableNativeMap();

                data.putBoolean(APP_LOCKED, isLockState());

                if (thisContext.hasActiveCatalystInstance()) {
                    thisContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit(APP_LOCK_STATUS_CHANGED, data);
                }
            }
        };
        thisContext.registerReceiver(appLockReceiver, appLockFilter);
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
        ActivityManager am = (ActivityManager) getReactApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);

        boolean isPinned = false;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            isPinned = am.getLockTaskModeState() == ActivityManager.LOCK_TASK_MODE_PINNED;
        }

        return dpm.isLockTaskPermitted(getReactApplicationContext().getPackageName()) && !isPinned;
    }

    public boolean isLockState() {
        ActivityManager am = (ActivityManager) getReactApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return am.getLockTaskModeState() != ActivityManager.LOCK_TASK_MODE_NONE;
        } else {
            return am.isInLockTaskMode();
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
        constants.put("APP_LOCK_STATUS_CHANGED", APP_LOCK_STATUS_CHANGED);
        constants.put("APP_LOCKED", APP_LOCKED);
        return constants;
    }

    private boolean isMDMSupported() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return false;
        }

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
    public void isAppLockAllowed(final Promise promise) {
        promise.resolve(isLockStatePermitted());
    }

    @ReactMethod
    public void isAppLocked(final Promise promise) {
        try {
          promise.resolve(isLockState());
        } catch (Exception e) {
          promise.reject(e);
        }
    }

    @ReactMethod
    public void lockApp(final Promise promise) {
        try {
            promise.resolve(enableLockState());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void unlockApp(final Promise promise) {
        try {
            promise.resolve(disableLockState());
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}

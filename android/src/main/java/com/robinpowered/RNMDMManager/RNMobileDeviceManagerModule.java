package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

// For MDM
import android.app.Activity;
import android.content.RestrictionsManager;
import android.app.ActivityManager;
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

public class RNMobileDeviceManagerModule extends ReactContextBaseJavaModule implements LifecycleEventListener {
    public static final String MODULE_NAME = "MobileDeviceManager";

    public static final String APP_CONFIG_CHANGED = "react-native-mdm/managedAppConfigDidChange";

    private BroadcastReceiver restrictionReceiver;

    public RNMobileDeviceManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private void maybeUnregisterReceiver() {
        if (restrictionReceiver == null) {
            return;
        }

        getReactApplicationContext().unregisterReceiver(restrictionReceiver);

        restrictionReceiver = null;
    }

    private void maybeRegisterReceiver() {
        final ReactApplicationContext reactContext = getReactApplicationContext();

        if (restrictionReceiver != null) {
            return;
        }

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
                if (reactContext.hasActiveCatalystInstance()) {
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit(APP_CONFIG_CHANGED, data);
                }
            }
        };
        reactContext.registerReceiver(restrictionReceiver,restrictionFilter);
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
        return true;
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
        return constants;
    }

    private boolean isMDMSupported() {
        // If app is running on any version that's older than lollipop, answer is no
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return false;
        }

        // Else, we look at restrictions manager and see if there's any app config settings in there
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
    public void isAppLockingAllowed(final Promise promise) {
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
            boolean locked = enableLockState();
            if (locked) {
              promise.resolve(locked);
            } else {
              promise.reject(new Error("Unable to lock app"));
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void unlockApp(final Promise promise) {
        try {
            boolean unlocked = disableLockState();
            if (unlocked) {
              promise.resolve(unlocked);
            } else {
              promise.reject(new Error("Unable to unlock app"));
            }
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    // Life cycle methods
    @Override
    public void initialize() {
        getReactApplicationContext().addLifecycleEventListener(this);
        maybeRegisterReceiver();
    }

    @Override
    public void onHostResume() {
        maybeRegisterReceiver();
    }

    @Override
    public void onHostPause() {
        maybeUnregisterReceiver();
    }

    @Override
    public void onHostDestroy() {
        maybeUnregisterReceiver();
        getReactApplicationContext().removeLifecycleEventListener(this);
    }
}

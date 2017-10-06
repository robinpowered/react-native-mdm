package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

// For MDM
import android.content.RestrictionsManager;
import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableNativeMap;
import android.util.Log;

public class RNMobileDeviceManagerModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    // RM - For MDM
    RestrictionsManager restrictionsManager;
    Bundle appRestrictions;
    IntentFilter restrictionFilter;
    BroadcastReceiver restrictionReceiver;

    public RNMobileDeviceManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        final ReactApplicationContext thisContext = reactContext;

        restrictionsManager = (RestrictionsManager) reactContext.getSystemService(Context.RESTRICTIONS_SERVICE);

        restrictionFilter = new IntentFilter(Intent.ACTION_APPLICATION_RESTRICTIONS_CHANGED);
        restrictionReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                appRestrictions = restrictionsManager.getApplicationRestrictions();
                WritableNativeMap data = new WritableNativeMap();
                for (String key : appRestrictions.keySet()){
                    data.putString(key, appRestrictions.getString(key));
                }
                if (thisContext.hasActiveCatalystInstance()) {
                    thisContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("userDefaultsDidChange", data);
                }
            }
        };
        thisContext.registerReceiver(restrictionReceiver,restrictionFilter);
    }

    @Override
    public String getName() {
        return "MobileDeviceManager";
    }

    private boolean isMDMSupported() {
        // Instantiating the restriction manager
        appRestrictions = restrictionsManager.getApplicationRestrictions();
        boolean isSupported = appRestrictions.size() > 0;
        return isSupported;
    }

    @ReactMethod
    public void isSupported(Callback successCallback) {
        if (isMDMSupported()) {
            successCallback.invoke(null, true);
        } else {
            successCallback.invoke(true, null);
        }
    }

    @ReactMethod
    public void getConfiguration(Callback successCallback) {
        if (isMDMSupported()) {
            // Instantiating the restriction manager
            appRestrictions = restrictionsManager.getApplicationRestrictions();
            WritableNativeMap data = new WritableNativeMap();
            for (String key : appRestrictions.keySet()){
                data.putString(key, appRestrictions.getString(key));
            }
            successCallback.invoke(null, data);
        } else {
            successCallback.invoke(true, null);
        }
    }
}

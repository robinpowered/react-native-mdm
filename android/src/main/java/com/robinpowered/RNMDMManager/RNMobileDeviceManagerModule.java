package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

// For MDM
import android.content.RestrictionsManager;
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
    // RM - For MDM
    private RestrictionsManager restrictionsManager;
    private Bundle appRestrictions;
    private IntentFilter restrictionFilter;
    private BroadcastReceiver restrictionReceiver;

    public RNMobileDeviceManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
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
                        .emit("react-native-mdm/managedAppConfigDidChange", data);
                }
            }
        };
        thisContext.registerReceiver(restrictionReceiver,restrictionFilter);
    }

    @Override
    public String getName() {
        return "MobileDeviceManager";
    }

    @Override
    public @Nullable Map<String, Object> getConstants() {
        HashMap<String, Object> constants = new HashMap<String, Object>();
        constants.put("managedAppConfigDidChange", "react-native-mdm/managedAppConfigDidChange");
        return constants;
    }

    private boolean isMDMSupported() {
        // Instantiating the restriction manager
        appRestrictions = restrictionsManager.getApplicationRestrictions();
        boolean isSupported = appRestrictions.size() > 0;
        return isSupported;
    }

    @ReactMethod
    public void isSupported(final Promise promise) {
        promise.resolve(isMDMSupported());
    }

    @ReactMethod
    public void getConfiguration(final Promise promise) {
        if (isMDMSupported()) {
            // Instantiating the restriction manager
            appRestrictions = restrictionsManager.getApplicationRestrictions();
            WritableNativeMap data = new WritableNativeMap();
            for (String key : appRestrictions.keySet()){
                data.putString(key, appRestrictions.getString(key));
            }
            promise.resolve(data);
        } else {
          promise.reject(new Error("Managed App Config is not supported"));
        }
    }
}

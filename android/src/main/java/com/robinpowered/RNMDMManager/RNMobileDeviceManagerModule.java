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
        if (thisContext.hasActiveCatalystInstance()) {
          thisContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit("userDefaultsDidChange", restrictionsManager.getApplicationRestrictions());
        }
      }
    };
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

	private Bundle getConfigs() {
		// Instantiating the restriction manager
		appRestrictions = restrictionsManager.getApplicationRestrictions();
		return appRestrictions;
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
			successCallback.invoke(null, getConfigs());
		} else {
			successCallback.invoke(true, null);
		}
	}
}


package com.robinpowered.RNMDMManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

// For MDM
import android.content.RestrictionsManager;
import android.os.Bundle;
import android.content.Context;

public class RNMobileDeviceManagerModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  // RM - For MDM
  RestrictionsManager restrictionsManager;
  Bundle appRestrictions;

  public RNMobileDeviceManagerModule(ReactApplicationContext reactContext) {
      super(reactContext);
      this.reactContext = reactContext;
      restrictionsManager = (RestrictionsManager) reactContext.getSystemService(Context.RESTRICTIONS_SERVICE);
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

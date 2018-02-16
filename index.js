'use strict';

import {
  DeviceEventEmitter,
  NativeModules
} from 'react-native';

const {MobileDeviceManager} = NativeModules;

export default {
  ...MobileDeviceManager,
  addAppConfigListener (callback) {
    return DeviceEventEmitter.addListener(
      MobileDeviceManager.APP_CONFIG_CHANGED,
      callback
    );
  },
  addAppLockListener (callback) {
    return DeviceEventEmitter.addListener(
      MobileDeviceManager.APP_LOCK_STATUS_CHANGED,
      callback
    );
  }
};

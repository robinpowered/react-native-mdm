'use strict';

import {
  DeviceEventEmitter,
  NativeModules
} from 'react-native';

const {MobileDeviceManager} = NativeModules;

export default {
  ...MobileDeviceManager,
  addListener (callback) {
    return DeviceEventEmitter.addListener(
      MobileDeviceManager.APP_CONFIG_CHANGED, callback
    );
  }
};

'use strict';

import {
  DeviceEventEmitter,
  NativeModules
} from 'react-native';

const {MobileDeviceManager} = NativeModules;

MobileDeviceManager.addListener = (callback) => {
  return DeviceEventEmitter.addListener(
    MobileDeviceManager.managedAppConfigDidChange, callback
  );
}

export default MobileDeviceManager;

'use strict';

import {
  DeviceEventEmitter,
  NativeModules
} from 'react-native';

const {MobileDeviceManager} = NativeModules;

const MDMManager = {
  isSupported () {
    return new Promise((resolve, reject) => {
      MobileDeviceManager.isSupported(error => {
        if (error) {
          return reject(false);
        }
        resolve(true);
      });
    });
  },

  getConfiguration () {
    return new Promise((resolve, reject) => {
      MobileDeviceManager.getConfiguration((error, result) => {
        if (error) {
          return reject('MDM is not supported');
        }
        resolve(result);
      });
    });
  },

  addListener (callback) {
    return DeviceEventEmitter.addListener(
      MobileDeviceManager.managedAppConfigDidChange, callback
    );
  }
};

export default MDMManager;

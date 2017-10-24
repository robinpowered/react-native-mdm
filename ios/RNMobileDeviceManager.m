#import "RNMobileDeviceManager.h"

// Used to send events to JS
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import "React/RCTBridge.h"
#endif

#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#elif __has_include("RCTEventDispatcher.h")
#import "RCTEventDispatcher.h"
#else
#import "React/RCTEventDispatcher.h"
#endif

@implementation MobileDeviceManager

@synthesize bridge = _bridge;

static NSString * const APP_CONFIG_CHANGED = @"react-native-mdm/managedAppConfigDidChange";

- (instancetype)init
{
    [ManagedAppConfigSettings clientInstance].delegate = self;
    [[ManagedAppConfigSettings clientInstance] start];

    return self;
}

- (void)dealloc
{
    [[ManagedAppConfigSettings clientInstance] end];
}

- (void) settingsDidChange:(NSDictionary<NSString *, id> *) changes {
    id appConfig = [[ManagedAppConfigSettings clientInstance] appConfig];
    [_bridge.eventDispatcher sendDeviceEventWithName:APP_CONFIG_CHANGED
                                                body:appConfig];
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"APP_CONFIG_CHANGED": APP_CONFIG_CHANGED };
}

RCT_EXPORT_METHOD(isSupported: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    id appConfig = [[ManagedAppConfigSettings clientInstance] appConfig];

    if (appConfig) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}

RCT_EXPORT_METHOD(getConfiguration:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    id appConfig = [[ManagedAppConfigSettings clientInstance] appConfig];

    if (appConfig) {
        resolve(appConfig);
    } else {
        reject(@"not-support", @"Managed App Config is not supported", nil);
    }
}


RCT_EXPORT_METHOD(isAutonomousSingleAppModeSupported: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didSucceed) {
        if (didSucceed) {
          UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didSucceed) {
            if (didSucceed) {
              resolve(@YES);
            }
          });
        }
        else {
          resolve(@NO);
        }
    });
}

RCT_EXPORT_METHOD(isAutonomousSingleAppModeEnabled: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(UIAccessibilityIsGuidedAccessEnabled())
}

RCT_EXPORT_METHOD(enableAutonomousSingleAppMode: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didSucceed) {
        if (didSucceed) {
          resolve(@YES);
        }
        else {
          resolve(@NO);
        }
    });
}

RCT_EXPORT_METHOD(disableAutonomousSingleAppMode: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didSucceed) {
        if (didSucceed) {
          resolve(@YES);
        }
        else {
          resolve(@NO);
        }
    });
}

@end

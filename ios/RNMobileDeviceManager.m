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

static NSString * const appConfigurationKey = @"com.apple.configuration.managed";
static NSString * const APP_CONFIG_CHANGED = @"react-native-mdm/managedAppConfigDidChange";

- (instancetype)init
{
    [ManagedAppConfigSettings clientInstance].delegate = self;
    [[ManagedAppConfigSettings clientInstance] start];

    return self;
}

- (void) settingsDidChange:(NSDictionary<NSString *, id> *) changes {
    id appConfig = [MobileDeviceManager getAppConfig];
    [_bridge.eventDispatcher sendDeviceEventWithName:APP_CONFIG_CHANGED
                                                body:appConfig];
}

+ (NSDictionary *)getAppConfig {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:appConfigurationKey];
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"APP_CONFIG_CHANGED": APP_CONFIG_CHANGED };
}

RCT_EXPORT_METHOD(isSupported: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    id appConfig = [MobileDeviceManager getAppConfig];

    if (appConfig) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}

RCT_EXPORT_METHOD(getConfiguration:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    id appConfig = [MobileDeviceManager getAppConfig];

    if (appConfig) {
        resolve(appConfig);
    } else {
        reject(@"not-support", @"Managed App Config is not supported", nil);
    }
}

@end

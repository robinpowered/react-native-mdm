#import "RNMobileDeviceManager.h"

// For RCTMakeError
#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#elif __has_include("RCTUtils.h")
#import "RCTUtils.h"
#else
#import "React/RCTUtils.h"
#endif

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
    if ((self = [super init])) {
        // Add Notification Center observer to be alerted of any change to NSUserDefaults.
        // Managed app configuration changes pushed down from an MDM server appear in NSUSerDefaults.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:@"NSUserDefaultsDidChangeNotification" object:nil];
    }

    return self;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
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
        reject(@"not-support", @"Managed App Config is not supported", @[RCTMakeError(@"Managed App Config is not supported", nil, nil)]);
    }
}

@end


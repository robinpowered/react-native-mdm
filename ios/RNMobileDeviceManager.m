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

    [_bridge.eventDispatcher sendDeviceEventWithName:@"react-native-mdm/managedAppConfigDidChange"
                                                body:appConfig];
}

+ (id)getAppConfig {
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";

    return [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationKey];
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
  return @{ @"managedAppConfigDidChange": @"react-native-mdm/managedAppConfigDidChange" };
}

RCT_EXPORT_METHOD(isSupported:(RCTResponseSenderBlock)callback)
{
    id appConfig = [MobileDeviceManager getAppConfig];

    if (appConfig) {
        callback(@[[NSNull null], @true]);
    } else {
        callback(@[RCTMakeError(@"Managed App Config is not supported", nil, nil)]);
        return;
    }
}

RCT_EXPORT_METHOD(getConfiguration:(RCTResponseSenderBlock)callback)
{
    id appConfig = [MobileDeviceManager getAppConfig];

    if (appConfig) {
        callback(@[[NSNull null], appConfig]);
    }
    else {
        callback(@[RCTMakeError(@"Managed App Config is not supported", nil, nil)]);
        return;
    }
}

@end


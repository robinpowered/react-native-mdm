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
    if ( self = [super init] ) {
        self.asamSem = dispatch_semaphore_create(1);
    }
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

- (void) isASAMSupported:(void(^)(BOOL))callback {
    if (UIAccessibilityIsGuidedAccessEnabled()) {
        dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
        UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didDisable) {
            if (didDisable) {
                UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didEnable) {
                    dispatch_semaphore_signal(self.asamSem);
                    callback(didEnable);
                });
            } else {
                dispatch_semaphore_signal(self.asamSem);
                callback(didDisable);
            }
        });
    } else {
        dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
        UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didEnable) {
            if (didEnable) {
                UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didDisable) {
                    dispatch_semaphore_signal(self.asamSem);
                    callback(didDisable);
                });
            } else {
                dispatch_semaphore_signal(self.asamSem);
                callback(didEnable);
            }
        });
    }
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
    [self isASAMSupported:^(BOOL isSupported){
        resolve(@(isSupported));
    }];

}

RCT_EXPORT_METHOD(isSingleAppModeEnabled: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(UIAccessibilityIsGuidedAccessEnabled()));
}

RCT_EXPORT_METHOD(isAutonomousSingleAppModeEnabled: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self isASAMSupported:^(BOOL isSupported){
        resolve(@((BOOL)(isSupported && UIAccessibilityIsGuidedAccessEnabled())));
    }];
}

RCT_EXPORT_METHOD(enableAutonomousSingleAppMode: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didSucceed) {
        resolve(@(didSucceed));
    });
}

RCT_EXPORT_METHOD(disableAutonomousSingleAppMode: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

    UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didSucceed) {
        resolve(@(didSucceed));
    });
}

@end

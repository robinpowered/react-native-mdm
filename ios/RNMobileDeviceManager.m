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

@interface MobileDeviceManager ()
@property dispatch_semaphore_t asamSem;
@property dispatch_queue_t queue;
@property dispatch_queue_t eventQueue;
@property BOOL guidedAccessCallbackRequired;
@property BOOL invalidated;
@end

@implementation MobileDeviceManager

@synthesize bridge = _bridge;

static NSString * const APP_CONFIG_CHANGED = @"react-native-mdm/managedAppConfigDidChange";
static NSString * const APP_LOCK_STATUS_CHANGED = @"react-native-mdm/appLockStatusDidChange";
static NSString * const APP_LOCKED = @"appLocked";
static NSString * const APP_LOCKING_ALLOWED = @"appLockingAllowed";
static char * const OPERATION_QUEUE_NAME = "com.robinpowered.RNMobileDeviceManager.OperationQueue";
static char * const NOTIFICATION_QUEUE_NAME = "com.robinpowered.RNMobileDeivceManager.NotificationQueue";

- (instancetype)init
{
    if (self = [super init]) {
        [ManagedAppConfigSettings clientInstance].delegate = self;
        [[ManagedAppConfigSettings clientInstance] start];

        self.asamSem = dispatch_semaphore_create(1);
        self.guidedAccessCallbackRequired = YES;
        self.invalidated = NO;
        self.eventQueue = dispatch_queue_create(NOTIFICATION_QUEUE_NAME, DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guidedAccessStatusChangeListenerCallback:) name:UIAccessibilityGuidedAccessStatusDidChangeNotification object:nil];
    }
    return self;
}

- (void)invalidate {
    self.invalidated = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[ManagedAppConfigSettings clientInstance] end];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsDidChange:(NSDictionary<NSString *, id> *)changes
{
    id appConfig = [[ManagedAppConfigSettings clientInstance] appConfig];
    [_bridge.eventDispatcher sendDeviceEventWithName:APP_CONFIG_CHANGED
                                                body:appConfig];
}

- (void)guidedAccessStatusChangeListenerCallback:(NSNotification*)notification
{
    if (self.invalidated) {
        return;
    }

    dispatch_async(_eventQueue, ^{
        if (_guidedAccessCallbackRequired != NO) {
            dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
            [self isSAMEnabled:^(BOOL isEnabled) {
                [self isASAMSupported:^(BOOL isAllowed) {
                    dispatch_semaphore_signal(self.asamSem);
                    [_bridge.eventDispatcher sendDeviceEventWithName:APP_LOCK_STATUS_CHANGED
                                                                body:(@{
                                                                        APP_LOCKED: @(isEnabled),
                                                                        APP_LOCKING_ALLOWED: @(isAllowed)
                                                                        })];
                }];
            }];
        }
    });
}

- (void) isASAMSupported:(void(^)(BOOL))callback
{
    _guidedAccessCallbackRequired = NO;

    void (^onComplete)(BOOL success) = ^(BOOL success){
        _guidedAccessCallbackRequired = YES;
        callback(success);
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIAccessibilityIsGuidedAccessEnabled()) {
            UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didDisable) {
                if (didDisable) {
                    UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didEnable) {
                        onComplete(didEnable);
                    });
                } else {
                    onComplete(didDisable);
                }
            });
        } else {
            UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didEnable) {
                if (didEnable) {
                    UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didDisable) {
                        onComplete(didDisable);
                    });
                } else {
                    onComplete(didEnable);
                }
            });
        }
    });
}

- (void) isSAMEnabled:(void(^)(BOOL))callback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isEnabled = UIAccessibilityIsGuidedAccessEnabled();
        callback(isEnabled);
    });
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"APP_CONFIG_CHANGED": APP_CONFIG_CHANGED,
              @"APP_LOCK_STATUS_CHANGED": APP_LOCK_STATUS_CHANGED,
              @"APP_LOCKED": APP_LOCKED,
              @"APP_LOCKING_ALLOWED": APP_LOCKING_ALLOWED };
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create(OPERATION_QUEUE_NAME, DISPATCH_QUEUE_SERIAL);
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


RCT_EXPORT_METHOD(isAppLockingAllowed: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
    [self isASAMSupported:^(BOOL isSupported){
        dispatch_semaphore_signal(self.asamSem);
        resolve(@(isSupported));
    }];

}

RCT_EXPORT_METHOD(isAppLocked: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
    [self isSAMEnabled:^(BOOL isEnabled) {
        dispatch_semaphore_signal(self.asamSem);
        resolve(@(isEnabled));
    }];
}

RCT_EXPORT_METHOD(lockApp: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAccessibilityRequestGuidedAccessSession(YES, ^(BOOL didSucceed) {
            dispatch_semaphore_signal(self.asamSem);
            if (didSucceed) {
                resolve(@(didSucceed));
            } else {
                reject(@"failed", @"Unable to lock app", nil);
            }
        });
    });
}

RCT_EXPORT_METHOD(unlockApp: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_semaphore_wait(self.asamSem, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAccessibilityRequestGuidedAccessSession(NO, ^(BOOL didSucceed) {
            dispatch_semaphore_signal(self.asamSem);
            if (didSucceed) {
                resolve(@(didSucceed));
            } else {
                reject(@"failed", @"Unable to unlock app", nil);
            }
        });
    });
}

@end

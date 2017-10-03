#import "RNMobileDeviceManager.h"

// For RCTMakeError
#import "RCTUtils.h"

// Used to send events to JS
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

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
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
    
    id response = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationKey];
    
    [_bridge.eventDispatcher sendDeviceEventWithName:@"userDefaultsDidChange"
                                                body:@{@"response": response}];
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(isSupported:(RCTResponseSenderBlock)callback)
{
    
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
    
    id response = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationKey];
    
    if (response) {
        callback(@[[NSNull null], @true]);
    } else {
        callback(@[RCTMakeError(@"Managed App Config is not supported", nil, nil)]);
        return;
    }
}

RCT_EXPORT_METHOD(getConfiguration:(RCTResponseSenderBlock)callback)
{
    
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
    
    id response = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigurationKey];
    
    if (response) {
        callback(@[[NSNull null], response]);
    }
    else {
        callback(@[[NSNull null], [NSNull null]]);
    }
}

@end


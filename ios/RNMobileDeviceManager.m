#import "RNMobileDeviceManager.h"
#import "RCTUtils.h"

@implementation MobileDeviceManager

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


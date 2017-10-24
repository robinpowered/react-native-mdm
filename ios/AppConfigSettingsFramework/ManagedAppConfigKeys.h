//
//  ManagedAppConfigKeys.h
//  AppConfigurationSample
//
//  Created by David Shaw on 2/3/16.
//  Copyright © 2016 AppConfig. All rights reserved.
//
#import <Foundation/Foundation.h>

/// App Service Configuration

/// Configuration
extern const NSString *kMDM_CONFIGURATION_KEY;
extern const NSString *kMDM_CACHED_CONFIGURATION_KEY;

// App Configuration
extern const NSString *kMDM_APP_ALLOW_ACCESS;
extern const NSString *kMDM_APP_CERTIFICATE_ALIAS;
extern const NSString *kMDM_APP_DEFAULT_BROWSER;
extern const NSString *kMDM_APP_DEFAULT_BROWSER_REQUIRED;

// Account Configuration
extern const NSString *kMDM_ACCOUNT_CERTIFICATE;
extern const NSString *kMDM_ACCOUNT_CERTIFICATE_NAME;
extern const NSString *kMDM_ACCOUNT_DESCRIPTION;
extern const NSString *kMDM_ACCOUNT_DISPLAY_NAME;
extern const NSString *kMDM_ACCOUNT_EMAIL;
extern const NSString *kMDM_ACCOUNT_HOST;
extern const NSString *kMDM_ACCOUNT_HOSTS;
extern const NSString *kMDM_ACCOUNT_PASSWORD;
extern const NSString *kMDM_ACCOUNT_PORT;
extern const NSString *kMDM_ACCOUNT_REQUIRE_CERT_AUTH;
extern const NSString *kMDM_ACCOUNT_SSL;
extern const NSString *kMDM_ACCOUNT_USERNAME;
extern const NSString *kMDM_ACCOUNT_USER_DOMAIN;

// Policy Configuration
extern const NSString *kMDM_APP_ALLOW_FILE_SAVE;
extern const NSString *kMDM_APP_ALLOW_FILE_SAVE_UNENCRYPTED;
extern const NSString *kMDM_APP_ALLOW_LOGGING;
extern const NSString *kMDM_APP_ALLOW_METRICS;
extern const NSString *kMDM_APP_ALLOW_PRINT;
extern const NSString *kMDM_APP_ALLOW_SELF_SIGNED_CERTS;
extern const NSString *kMDM_APP_ALLOW_SETTINGS_EDIT;
extern const NSString *kMDM_APP_OPEN_IN_WHITELIST;
extern const NSString *kMDM_APP_RESTRICT_COPY_PASTE;
extern const NSString *kMDM_APP_RESTRICT_OPEN_IN;

// App Password Policy
extern const NSString *kMDM_APP_PASSCODE_ALLOW_SIMPLE;
extern const NSString *kMDM_APP_PASSCODE_ATTEMPTS;
extern const NSString *kMDM_APP_PASSCODE_COMPLEX;
extern const NSString *kMDM_APP_PASSCODE_HISTORY;
extern const NSString *kMDM_APP_PASSCODE_LENGTH;
extern const NSString *kMDM_APP_PASSCODE_MAX_AGE;
extern const NSString *kMDM_APP_PASSCODE_TIMEOUT;
extern const NSString *kMDM_APP_PASSCODE_TYPE;

// User Configuration
extern const NSString *kMDM_USER_GROUP_CODE;

// Branding
extern const NSString *kMDM_BRANDING_BACKGROUND;
extern const NSString *kMDM_BRANDING_LOGO;
extern const NSString *kMDM_BRANDING_NAME;

// App Tutorial Override
extern const NSString *kMDM_APP_SKIP_TUTORIAL;

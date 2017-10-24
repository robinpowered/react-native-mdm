//  Created by David Shaw on 2/3/16.

#import "ManagedAppConfigKeys.h"

/// Configuration
NSString const *kMDM_CONFIGURATION_KEY = @"com.apple.configuration.managed";
NSString const *kMDM_CACHED_CONFIGURATION_KEY =
    @"com.appconfig.configuration.persisted";

// App Configuration
NSString const *kMDM_APP_ALLOW_ACCESS = @"AppAllowAccess";
NSString const *kMDM_APP_CERTIFICATE_ALIAS = @"AppManagedCertAlias";
NSString const *kMDM_APP_DEFAULT_BROWSER = @"AppDefaultBrowser";
NSString const *kMDM_APP_DEFAULT_BROWSER_REQUIRED = @"AppRequireDefaultBrowser";

// Account Configuration
NSString const *kMDM_ACCOUNT_CERTIFICATE = @"AccountLoginCertificate";
NSString const *kMDM_ACCOUNT_CERTIFICATE_NAME = @"AccountLoginCertificateName";
NSString const *kMDM_ACCOUNT_DESCRIPTION = @"AccountName";
NSString const *kMDM_ACCOUNT_DISPLAY_NAME = @"AccountUserDisplayName";
NSString const *kMDM_ACCOUNT_EMAIL = @"AccountEmail";
NSString const *kMDM_ACCOUNT_HOST = @"AccountServiceHost";
NSString const *kMDM_ACCOUNT_HOSTS = @"AccountServiceHosts";
NSString const *kMDM_ACCOUNT_PASSWORD = @"AccountPassword";
NSString const *kMDM_ACCOUNT_PORT = @"AccountServicePort";
NSString const *kMDM_ACCOUNT_REQUIRE_CERT_AUTH = @"AccountRequireCertAuth";
NSString const *kMDM_ACCOUNT_SSL = @"AccountRequireSSL";
NSString const *kMDM_ACCOUNT_USERNAME = @"AccountUsername";
NSString const *kMDM_ACCOUNT_USER_DOMAIN = @"AccountDomain";

// Policy Configuration
NSString const *kMDM_APP_ALLOW_FILE_SAVE = @"PolicyAllowFileSave";
NSString const *kMDM_APP_ALLOW_FILE_SAVE_UNENCRYPTED =
    @"PolicyAllowFileSaveUnencrypted";
NSString const *kMDM_APP_ALLOW_LOGGING = @"PolicyAllowLogging";
NSString const *kMDM_APP_ALLOW_METRICS = @"PolicyAllowMetrics";
NSString const *kMDM_APP_ALLOW_PRINT = @"PolicyAllowPrint";
NSString const *kMDM_APP_ALLOW_SELF_SIGNED_CERTS =
    @"PolicyAllowSelfSignedCerts";
NSString const *kMDM_APP_ALLOW_SETTINGS_EDIT = @"PolicyAllowSettingEdit";
NSString const *kMDM_APP_OPEN_IN_WHITELIST = @"PolicyDocumentSharingWhitelist";
NSString const *kMDM_APP_RESTRICT_COPY_PASTE = @"PolicyRestrictCopyPaste";
NSString const *kMDM_APP_RESTRICT_OPEN_IN = @"PolicyRestrictDocumentSharing";

// App Password Policy
NSString const *kMDM_APP_PASSCODE_ALLOW_SIMPLE = @"AppPasscodeAllowSimple";
NSString const *kMDM_APP_PASSCODE_ATTEMPTS = @"AppPasscodeAttempts";
NSString const *kMDM_APP_PASSCODE_COMPLEX = @"AppPasscodeComplex";
NSString const *kMDM_APP_PASSCODE_HISTORY = @"AppPasscodeHistory";
NSString const *kMDM_APP_PASSCODE_LENGTH = @"AppPasscodeLength";
NSString const *kMDM_APP_PASSCODE_MAX_AGE = @"AppPasscodeMaxAge";
NSString const *kMDM_APP_PASSCODE_TIMEOUT = @"AppPasscodeTimeout";
NSString const *kMDM_APP_PASSCODE_TYPE = @"AppPasscodeType";

// User Configuration
NSString const *kMDM_USER_GROUP_CODE = @"UserGroupCode";

// Branding
NSString const *kMDM_BRANDING_BACKGROUND = @"BrandingBackground";
NSString const *kMDM_BRANDING_LOGO = @"BrandingLogo";
NSString const *kMDM_BRANDING_NAME = @"BrandingName";

// App Tutorial Override
NSString const *kMDM_APP_SKIP_TUTORIAL = @"AppSkipTutorial";

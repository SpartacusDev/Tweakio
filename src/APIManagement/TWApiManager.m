#import "TWApiManager.h"
#import "src/common.h"
#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>


@interface TWApiManager ()

@property (nonatomic, strong) HBPreferences *prefs;
@property (nonatomic, strong) NSString *packageManager;

@end

@implementation TWApiManager

+ (instancetype)sharedInstance {
    static TWApiManager *sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
        self.packageManager = getPackageManager();
    }
    return self;
}

- (NSArray<__kindof TWBaseApi *> *)options {
    static NSMutableArray<__kindof TWBaseApi *> *apiHandlers = nil;
    static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
        apiHandlers = [[NSMutableArray alloc] init];
		int numClasses;
        Class *classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 ) {
            classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                if (class_getSuperclass(classes[i]) == [TWBaseApi class]) {
                    [apiHandlers addObject:[[classes[i] alloc] init]];
                }
            }
            free(classes);
        }
	});
    return [apiHandlers copy];
}

- (NSArray<__kindof TWBaseRatingsApi *> *)ratingsOptions {
    static NSMutableArray<__kindof TWBaseApi *> *apiHandlers = nil;
    static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
        apiHandlers = [[NSMutableArray alloc] init];
		int numClasses;
        Class *classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 ) {
            classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                if (class_getSuperclass(classes[i]) == [TWBaseRatingsApi class]) {
                    [apiHandlers addObject:[[classes[i] alloc] init]];
                }
            }
            free(classes);
        }
	});
    return [apiHandlers copy];
}

- (TWBaseRatingsApi *)ratingsApiForKey:(NSString *)key {
    for (TWBaseRatingsApi *api in [self ratingsOptions]) {
        if ([api.prefsValue isEqualToString:key]) {
            return api;
        }
    }
    return nil;
}

- (TWBaseApi *)apiForKey:(NSString *)key {
    for (TWBaseApi *api in [self options]) {
        if ([api.prefsValue isEqualToString:key]) {
            return api;
        }
    }
    return nil;
}

- (BOOL)apiExistsForPrefsValue:(NSString *)prefsValue {
    for (__kindof TWBaseApi *apiHandler in [self options]) {
        if ([apiHandler.prefsValue isEqualToString:prefsValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)search:(NSString *)query api:(NSString *)api onNoConfirmation:(void (^)(NSString *))onNoConfirmation onFinish:(void (^)(NSArray<Result *> *))onFinish error:(NSError **)error {
    __kindof TWBaseApi *apiHandler = [self apiForKey:api];

    if (apiHandler == nil) {
        [NSException raise:@"Failed to find API handler" format:@"Couldn't find API handler for key %@", api];
    }

    NSString *key = [NSString stringWithFormat:@"%@-PrivacyPolicyTOS", apiHandler.prefsValue];

    if (![self.prefs boolForKey:key default:NO] && (apiHandler.tos != nil || apiHandler.privacyPolicy != nil)) {
        onNoConfirmation(api);
        return;
    }

    [apiHandler search:query error:error completionHandler:onFinish];
}

- (void)ratingsSearch:(Result *)query api:(NSString *)api onNoConfirmation:(void (^)(NSString *))onNoConfirmation onFinish:(void (^)(float, NSArray<TWReview *> *))onFinish error:(NSError **)error {
    __kindof TWBaseRatingsApi *apiHandler = [self ratingsApiForKey:api];

    if (apiHandler == nil) {
        [NSException raise:@"Failed to find API handler" format:@"Couldn't find API handler for key %@", api];
    }

    NSString *key = [NSString stringWithFormat:@"%@-PrivacyPolicyTOS", apiHandler.prefsValue];

    if (![self.prefs boolForKey:key default:NO] && (apiHandler.tos != nil || apiHandler.privacyPolicy != nil)) {
        onNoConfirmation(api);
        return;
    }

    [apiHandler search:query error:error completionHandler:onFinish];
}

- (void)viewController:(UIViewController *)viewController apiTOSAndPrivacyPolicy:(NSString *)api ratings:(BOOL)ratings completionHandler:(void (^)(void))closure {
    __kindof TWBaseApi *apiHandler;
    if (ratings) {
        apiHandler = (__kindof TWBaseApi *)[self ratingsApiForKey:api];
    } else {
        apiHandler = [self apiForKey:api];
    }

    if (apiHandler == nil) {
        [NSException raise:@"Failed to find API handler" format:@"Couldn't find API handler for key %@", api];
    }

    NSURL *privacyPolicy = apiHandler.privacyPolicy;
    NSURL *tos = apiHandler.tos;

    if (tos == nil && privacyPolicy == nil) {
        return;
    }

    NSString *key = [NSString stringWithFormat:@"%@-PrivacyPolicyTOS", apiHandler.prefsValue];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy Policy and/or TOS" 
            message:[NSString stringWithFormat:@"Before using %@, please check their privacy policy and tos.", apiHandler.name] 
            preferredStyle:UIAlertControllerStyleAlert
        ];

        __block BOOL confirmAdded = NO;

        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.prefs setBool:YES forKey:key];
            closure();
        }];
        if (privacyPolicy != nil) {
            UIAlertAction *privacyPolicyAction = [UIAlertAction actionWithTitle:@"Privacy Policy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:privacyPolicy options:@{} completionHandler:^(BOOL success){
                    if (!confirmAdded) {
                        [alert addAction:confirm];
                        confirmAdded = YES;
                    }
                    [viewController presentViewController:alert animated:YES completion:NULL];
                }];
            }];
            [alert addAction:privacyPolicyAction];
        }
        if (tos != nil) {
            UIAlertAction *tosAction = [UIAlertAction actionWithTitle:@"Terms of Service" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:tos options:@{} completionHandler:^(BOOL success){
                    if (!confirmAdded) {
                        [alert addAction:confirm];
                        confirmAdded = YES;
                    }
                    [viewController presentViewController:alert animated:YES completion:NULL];
                }];
            }];
            [alert addAction:tosAction];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [self.prefs setBool:NO forKey:key];
        }];

        [alert addAction:cancel];

        [viewController presentViewController:alert animated:YES completion:NULL];
    });
}

@end
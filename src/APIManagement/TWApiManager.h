#import <Foundation/Foundation.h>
#import "src/Backend/Result.h"
#import "TWBaseApi.h"
#import "TWBaseRatingsApi.h"


@interface TWApiManager : NSObject

+ (instancetype)sharedInstance;
- (void)search:(NSString *)query error:(NSError **)error api:(NSString *)api onNoConfirmation:(void (^)(NSString *))onNoConfirmation onFinish:(void (^)(NSArray<Result *> *, NSError *))onFinish;
- (void)ratingsSearch:(Result *)query error:(NSError **)error api:(NSString *)api onNoConfirmation:(void (^)(NSString *))onNoConfirmation onFinish:(void (^)(float, NSArray<TWReview *> *, NSError *))onFinish;
- (NSArray<__kindof TWBaseApi *> *)options;
- (NSArray<__kindof TWBaseRatingsApi *> *)ratingsOptions;
- (TWBaseRatingsApi *)ratingsApiForKey:(NSString *)key;
- (TWBaseApi *)apiForKey:(NSString *)key;
- (BOOL)apiExistsForPrefsValue:(NSString *)prefsValue;
- (void)viewController:(UIViewController *)viewController apiTOSAndPrivacyPolicy:(NSString *)api ratings:(BOOL)ratings completionHandler:(void (^)(void))closure;

@end

#import <Foundation/Foundation.h>
#import "src/Backend/Result.h"


@interface TWBaseApi : NSObject

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong) NSString *prefsValue;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *apiDescription;
NS_ASSUME_NONNULL_END
@property (nonatomic, strong, nullable) NSURL *privacyPolicy;
@property (nonatomic, strong, nullable) NSURL *tos;
@property (nonatomic, strong, nullable) NSArray<NSString *> *options;

NS_ASSUME_NONNULL_BEGIN
- (void)search:(NSString *)query completionHandler:(void (^)(NSArray<Result *> *, NSError *))completionHandler;
NS_ASSUME_NONNULL_END

@end
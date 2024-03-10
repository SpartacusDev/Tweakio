#import <Foundation/Foundation.h>


@interface TWBaseApi : NSObject 

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *apiDescription;

@end

@interface TWBaseRatingsApi : NSObject 

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *apiDescription;

@end


@interface TWApiManager : NSObject

+ (instancetype)sharedInstance;
- (NSArray<__kindof TWBaseApi *> *)options;
- (NSArray<__kindof TWBaseRatingsApi *> *)ratingsOptions;

@end

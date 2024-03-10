#import "TWBaseApi.h"


@interface TWBaseApi ()

@end


@implementation TWBaseApi

- (void)search:(NSString *)query error:(NSError **)error completionHandler:(void (^)(NSArray<Result *> *))completionHandler {
    [NSException raise:@"Method - (void)search:error:completionHandler: not defined" format:@"This method needs to be defined in a subclass"];
}

@end
#import "TWBaseApi.h"


@interface TWBaseApi ()

@end


@implementation TWBaseApi

- (void)search:(NSString *)query completionHandler:(void (^)(NSArray<Result *> *, NSError *))completionHandler {
    completionHandler(nil, [[NSError alloc] initWithDomain:@"com.spartacus.tweakio" code:1 userInfo:@{   
        NSLocalizedDescriptionKey: @"Method not implemented",
        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Method [%@ search:completionHandler:] is not implemented", NSStringFromClass(self.class)]
    }]);
}

@end
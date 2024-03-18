#import "TWBaseRatingsApi.h"


@interface TWBaseRatingsApi ()

@end


@implementation TWBaseRatingsApi

- (void)search:(Result *)package completionHandler:(void (^)(float, NSArray<TWReview *> *, NSError *))completionHandler {
    completionHandler(-1, nil, [[NSError alloc] initWithDomain:@"com.spartacus.tweakio" code:1 userInfo:@{   
        NSLocalizedDescriptionKey: @"Method not implemented",
        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Method [%@ search:completionHandler:] is not implemented", NSStringFromClass(self.class)]
    }]);
}

@end
#import "TWBaseRatingsApi.h"


@interface TWBaseRatingsApi ()

@end


@implementation TWBaseRatingsApi

- (void)search:(Result *)package error:(NSError **)error completionHandler:(void (^)(float, NSArray<TWReview *> *))completionHandler {
    [NSException raise:@"Method - (void)search:error:completionHandler: not defined" format:@"This method needs to be defined in a subclass"];
}

@end
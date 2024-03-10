#import <UIKit/UIKit.h>
#import "src/Backend/TWReview.h"


@interface TWReviewViewController : UITableViewController

- (instancetype)initWithReviews:(NSArray<TWReview *> *)reviews;

@end

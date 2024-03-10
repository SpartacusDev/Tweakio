#import <UIKit/UIKit.h>
#import "src/Backend/Result.h"

@interface TweakioViewController : UITableViewController<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;

- (instancetype)initWithPackageManager:(NSString *)packageManager;

@end

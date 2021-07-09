#import <UIKit/UIKit.h>
// #import "UITableViewCell+CydiaLike.h"
// #import "TweakViewController.h"
#import "Result.h"


@interface TweakioResultsViewController : UITableViewController

@property (nonatomic, strong) NSArray<Result *> *results;
@property (nonatomic, strong) NSString *packageManager;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController andPackageManager:(NSString *)packageManager;
- (void)startAnimating;
- (void)setupWithResults:(NSArray<Result *> *)results;
- (void)clear;

@end

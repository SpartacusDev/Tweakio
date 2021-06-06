#import <UIKit/UIKit.h>
#import "Result.h"


@interface TweakioResultsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<Result *> *results;
@property (nonatomic, strong) NSString *packageManager;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController andPackageManager:(NSString *)packageManager;
- (void)setupWithResults:(NSArray<Result *> *)results andBackgroundColor:(UIColor *)backgroundColor;
- (void)clear;

@end

#import <UIKit/UIKit.h>
#import "Result.h"

@interface TweakioViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic, strong) NSString *packageManager;

- (instancetype)initWithPackageManager:(NSString *)packageManager;

@end


NSArray<Result *> *spartacusAPI(NSString *query);
NSArray<Result *> *parcilityAPI(NSString *query);
NSArray<Result *> *canisterAPI(NSString *query);
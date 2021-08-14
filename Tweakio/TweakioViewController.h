// #import "TweakioResultsViewController.h"
#import <UIKit/UIKit.h>
#import "Result.h"

@interface TweakioViewController : UITableViewController<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;

- (instancetype)initWithPackageManager:(NSString *)packageManager;

@end


NSArray<Result *> *spartacusAPI(NSString *query, BOOL fast);
NSArray<Result *> *parcilityAPI(NSString *query);
NSArray<Result *> *canisterAPI(NSString *query);
NSArray<Result *> *iosrepoupdatesAPI(NSString *query);

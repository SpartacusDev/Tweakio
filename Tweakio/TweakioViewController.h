#import <UIKit/UIKit.h>
#import "Result.h"

@interface TweakioViewController : UIViewController<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;

- (instancetype)initWithPackageManager:(NSString *)packageManager;

@end


NSArray<Result *> *spartacusAPI(NSString *query);
NSArray<Result *> *parcilityAPI(NSString *query);
NSArray<Result *> *canisterAPI(NSString *query);

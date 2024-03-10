#import <UIKit/UIKit.h>
#import "src/Backend/Result.h"

@interface TweakViewController : UITableViewController

@property (nonatomic, strong) NSString *packageManager;

- (instancetype)initWithPackage:(Result *)package andPackageManager:(NSString *)packageManager;

@end

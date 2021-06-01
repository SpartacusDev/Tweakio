#import <UIKit/UIKit.h>


// Cydia

@interface Cydia : UIApplication

@end


@interface HomeController : UIViewController

- (void)aboutButtonClicked;

@end


// Zebra

@interface ZBAppDelegate : UIResponder

@property (nonatomic, strong) UIWindow *window;

@end


@interface ZBSearchTableViewController : UIViewController

@property (assign) BOOL pushed;

@end


@interface ZBSearchResultsTableViewController : UIViewController

@property (assign) BOOL pushed;

@end


@interface ZBPackageDepictionViewController : UIViewController

@end


@interface ZBSettingsTableViewController : UITableViewController

@end


// Installer

@interface ATInstaller : UIResponder

@property (nonatomic, strong) UIWindow *window;

@end


@interface AccountPlistViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@end

#import "Tweakio/TweakioViewController.h"


// Cydia

@interface Cydia : UIApplication

@end


@interface HomeController : UIViewController

- (void)aboutButtonClicked;

@end

@interface SearchController : UIViewController

@property (nonatomic, strong) TweakioViewController *tweakio;

@end


// Zebra

@interface ZBAppDelegate : UIResponder

@property (nonatomic, strong) UIWindow *window;

@end


@interface ZBSearchTableViewController : UIViewController

@property (nonatomic, strong) TweakioViewController *tweakio;

@end


// Installer

@interface ATInstaller : UIResponder

@property (nonatomic, strong) UIWindow *window;

@end


@interface AccountPlistViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@end

@interface SearchViewController : UIViewController

@property (nonatomic, strong) TweakioViewController *tweakio;

@end


// Sileo

@interface _TtC5Sileo25PackageListViewController : UIViewController

@property (nonatomic, strong) TweakioViewController *tweakio;
@property (assign) BOOL showWishlist;
@property (nonatomic, strong) NSString *packagesLoadIdentifier;

@end



// Tweakio App

@interface TWAppDelegate : UIResponder<UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@end

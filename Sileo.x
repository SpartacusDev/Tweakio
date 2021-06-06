#import <objc/runtime.h>
#import "HookHeaders.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook SileoAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig(application);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *sileo = (NSNumber *)[prefs objectForKey:@"sileo"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"sileo hooking method"];
	if ((sileo && !sileo.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return;


    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Sileo"]];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
    UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
    [navController setTabBarItem:tweakioTabBarItem];
    
    UIWindow *window = [self performSelector:@selector(window)];
    NSMutableArray *controllers = [((UITabBarController *)window.rootViewController).viewControllers mutableCopy];

    [controllers addObject:navController];
    [((UITabBarController *)window.rootViewController) setViewControllers:controllers];
    [self performSelector:@selector(setWindow:) withObject:window];
}

%end

%hook _TtC5Sileo25PackageListViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *sileo = (NSNumber *)[prefs objectForKey:@"sileo"];
    NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"sileo hooking method"];
	if ((sileo && !sileo.boolValue) || (hookingMethod && hookingMethod.intValue != 1) || (NSObject *)object_getIvar(self, class_getInstanceVariable(self.class, "repoContext")) || self.showWishlist) return;

    self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Sileo"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *animation = [prefs objectForKey:@"sileo animation"];

	if (animation && !animation.boolValue) {
		[self.navigationController pushViewController:self.tweakio animated:NO];
		return;
	}
	
    CATransition *transition = [[CATransition alloc] init];
	[transition setDuration:0.3];
	[transition setType:@"flip"];
	[transition setSubtype:kCATransitionFromLeft];
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	
	[self.navigationController pushViewController:self.tweakio animated:NO];
}

%end

%hook SileoSettingsViewController

// - (void)viewDidLoad {
// 	%orig;
//     NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
// 	NSObject *sileo = [prefs objectForKey:@"sileo"];
// 	if (sileo && ![sileo performSelector:@selector(boolValue)]) return;
// 	UIBarButtonItem *tweakioSettings = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakioSettings:)];
// 	[[self performSelector:@selector(navigationItem)] performSelector:@selector(setLeftBarButtonItem:) withObject:tweakioSettings];
// }

// %new - (void)openTweakioSettings:(UIBarButtonItem *)sender {
// 	[(UINavigationController *)[self performSelector:@selector(navigationController)] pushViewController:[[Settings alloc] initWithPackageManager:@"Sileo" andBackgroundColor:((UIView *)[self performSelector:@selector(view)]).backgroundColor] animated:YES];
// }

%end

%ctor {
    %init(SileoAppDelegate = NSClassFromString(@"Sileo.AppDelegate"), SileoSettingsViewController = NSClassFromString(@"Sileo.SettingsViewController"));
}

#import "Tweakio/ZBMoreViewController.h"
#import "Tweakio/TweakioViewController.h"
#import "Settings/Settings.h"
#import "HookHeaders.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"

%group ZBiPhones

%hook ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *zebra = [prefs objectForKey:@"zebra"];
	if (zebra && ![zebra performSelector:@selector(boolValue)]) return original;

	if (original) {
		NSMutableArray *controllers = [((UITabBarController *)self.window.rootViewController).viewControllers mutableCopy];
		ZBMoreViewController *more = [[ZBMoreViewController alloc] init];
		UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:more];
		UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:controllers.count];
		[navcont setTabBarItem:searchTabBarItem];
		[more.viewControllers addObject:((UINavigationController *)controllers.lastObject).viewControllers.firstObject];
		[more.viewControllers addObject:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];
		// UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[%c(ZBMoreViewController) alloc] init]];
		// // UIImage *icon = [UIImage systemImageNamed:@"more"];
		// UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:nil selectedImage:nil];
		// [navController setTabBarItem:tweakioTabBarItem];

		// NSMutableArray *controllers = [((UITabBarController *)self.window.rootViewController).viewControllers mutableCopy];

		// UINavigationController *search = [[UINavigationController alloc] initWithRootViewController:((UINavigationController *)controllers.lastObject).viewControllers.firstObject];
		// UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:controllers.count];
		// [searchTabBarItem setTitle:((UINavigationController *)controllers.lastObject).tabBarItem.title];
		// [search setTabBarItem:searchTabBarItem];

		[controllers removeObject:controllers.lastObject];
		// [controllers addObject:search];
		// [controllers addObject:navController];
		[controllers addObject:navcont];

		[((UITabBarController *)self.window.rootViewController) setViewControllers:controllers];
	}
	return original;
}

%end

%end

%group ZBiPads

%hook ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *zebra = [prefs objectForKey:@"zebra"];
	if (zebra && ![zebra performSelector:@selector(boolValue)]) return original;

	if (original) {
		NSMutableArray *controllers = [((UINavigationController *)self.window.rootViewController).viewControllers mutableCopy];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];

		NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
		UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
		UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
		[navController setTabBarItem:tweakioTabBarItem];
		[controllers addObject:navController];

		[((UINavigationController *)self.window.rootViewController) setViewControllers:controllers];
	}

	return original;
}

%end

%end

%hook ZBSettingsTableViewController

- (void)viewDidLoad {
	%orig;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *zebra = [prefs objectForKey:@"zebra"];
	if (zebra && ![zebra performSelector:@selector(boolValue)]) return;
	UIBarButtonItem *tweakioSettings = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakioSettings:)];
	[self.navigationItem setLeftBarButtonItem:tweakioSettings];
}

%new - (void)openTweakioSettings:(UIBarButtonItem *)sender {
	[self.navigationController pushViewController:[[Settings alloc] initWithPackageManager:@"Zebra" andBackgroundColor:self.view.backgroundColor] animated:YES];
}

%end

%ctor {
	%init(_ungrouped);
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) %init(ZBiPads);
	else %init(ZBiPhones);
}
#import "HookHeaders.h"
#import "Tweakio/ZBMoreViewController.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook ZBSearchTableViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Zebra"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *animation = [prefs objectForKey:@"zebra animation"];

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

%group ZBiPhones

%hook ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;

	if (original) {
		NSMutableArray *controllers = [((UITabBarController *)self.window.rootViewController).viewControllers mutableCopy];
		ZBMoreViewController *more = [[ZBMoreViewController alloc] init];
		UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:more];
		UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:controllers.count];
		[navcont setTabBarItem:searchTabBarItem];
		[more.viewControllers addObject:((UINavigationController *)controllers.lastObject).viewControllers.firstObject];
		[more.viewControllers addObject:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];

		[controllers removeObject:controllers.lastObject];
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
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;

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

%ctor {
	%init(_ungrouped);
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) %init(ZBiPads);
	else %init(ZBiPhones);
}
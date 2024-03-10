#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#import "src/UI/TWMoreViewController.h"
#import "src/common.h"


%hook ZBSearchTableViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	[self setTweakio:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [[self navigationItem] setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[[self tweakio] setBackgroundColor:[self view].backgroundColor];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *animation = [prefs objectForKey:@"zebra animation"];

	if (animation && !animation.boolValue) {
		[[self navigationController] pushViewController:[self tweakio] animated:NO];
		return;
	}
	
    CATransition *transition = [[CATransition alloc] init];
	[transition setDuration:0.3];
	[transition setType:@"flip"];
	[transition setSubtype:kCATransitionFromLeft];
	[[self navigationController].view.layer addAnimation:transition forKey:kCATransition];
	
	[[self navigationController] pushViewController:[self tweakio] animated:NO];
}

%end

%group ZBiPhones

%hook ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;

	if (original) {
		if (self.window.rootViewController.class == NSClassFromString(@"ZBRefreshViewController")) {
			return original;
		}

		NSMutableArray<UINavigationController *> *controllers = [((UITabBarController *)self.window.rootViewController).viewControllers mutableCopy];
		TWMoreViewController *more = [[TWMoreViewController alloc] init];
		UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:more];
		UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:controllers.count];
		[navcont setTabBarItem:searchTabBarItem];

		TweakioViewController *tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Zebra"];

		[more.viewControllers addObject:controllers.lastObject.viewControllers.firstObject];
		[more.viewControllers addObject:tweakio];

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

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;

	if (original) {
		if (self.window.rootViewController.class == NSClassFromString(@"ZBRefreshViewController")) {
			return original;
		}

		NSMutableArray *controllers = [((UINavigationController *)self.window.rootViewController).viewControllers mutableCopy];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];

		NSBundle *bundle = [[NSBundle alloc] initWithPath:BUNDLE_PATH];
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

%group ZBNew

%hook ZBTabBarController

- (void)setViewControllers:(NSArray *)viewControllers {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	
	if (!((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0))) {
		if (viewControllers.count == 4) {
			viewControllers = [viewControllers mutableCopy];

			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Zebra"]];

			NSBundle *bundle = [[NSBundle alloc] initWithPath:BUNDLE_PATH];
			UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
			UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
			[navController setTabBarItem:tweakioTabBarItem];
			[(NSMutableArray *)(viewControllers) addObject:navController];

			viewControllers = [viewControllers copy];
		}
	}

	%orig(viewControllers);
}

%end

%end

%ctor {
	Class zbSearch = NSClassFromString(@"ZBSearchTableViewController");
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"xyz.willy.Zebralpha"]) {
		%init(ZBNew);
		zbSearch = NSClassFromString(@"ZBSearchViewController");
	} else {
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			%init(ZBiPads);
		else
			%init(ZBiPhones);
	}
	%init(ZBSearchTableViewController=zbSearch);
}
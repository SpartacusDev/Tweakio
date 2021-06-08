#import <objc/runtime.h>
#import "HookHeaders.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook SearchController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *cydia = (NSNumber *)[prefs objectForKey:@"cydia"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"cydia hooking method"];
	if ((cydia && !cydia.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Cydia"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *animation = [prefs objectForKey:@"cydia animation"];

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


%hook Cydia

- (void)loadData {
	%orig;

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSNumber *cydia = (NSNumber *)[prefs objectForKey:@"cydia"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"cydia hooking method"];
	if ((cydia && !cydia.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return;

	UIWindow *window = (UIWindow *)object_getIvar(self, class_getInstanceVariable([self class], "window_"));

	if (((UINavigationController *)(window.rootViewController)).viewControllers.count < 6) {
		NSMutableArray<UINavigationController *> *controllers = [((UINavigationController *)window.rootViewController).viewControllers mutableCopy];

		TweakioViewController *tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Cydia"];
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tweakio];
		NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
		UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
		UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
		[navController setTabBarItem:tweakioTabBarItem];

		[controllers addObject:navController];
		[(UINavigationController *)(window.rootViewController) setViewControllers:[controllers copy]];
	}
}

%end

%ctor {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableDictionary *prefs;
	if ([fileManager fileExistsAtPath:preferencesPath]) {
		prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesPath];
	} else {
		[fileManager createFileAtPath:preferencesPath contents:nil attributes:nil];
		prefs = [NSMutableDictionary dictionary];
	}

	if (![prefs objectForKey:@"Cydia API"]) prefs[@"Cydia API"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"Zebra API"]) prefs[@"Zebra API"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"Installer API"]) prefs[@"Installer API"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"Sileo API"]) prefs[@"Sileo API"] = [NSNumber numberWithInteger:0];
	
	if (![prefs objectForKey:@"cydia hooking method"]) prefs[@"cydia hooking method"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"zebra hooking method"]) prefs[@"zebra hooking method"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"installer hooking method"]) prefs[@"installer hooking method"] = [NSNumber numberWithInteger:0];
	if (![prefs objectForKey:@"sileo hooking method"]) prefs[@"sileo hooking method"] = [NSNumber numberWithInteger:0];
	
	if (![prefs objectForKey:@"cydia animation"]) prefs[@"cydia animation"] = [NSNumber numberWithBool:YES];
	if (![prefs objectForKey:@"zebra animation"]) prefs[@"zebra animation"] = [NSNumber numberWithBool:YES];
	if (![prefs objectForKey:@"installer animation"]) prefs[@"installer animation"] = [NSNumber numberWithBool:YES];
	if (![prefs objectForKey:@"sileo animation"]) prefs[@"sileo animation"] = [NSNumber numberWithBool:YES];

	if (![prefs objectForKey:@"cydia legacy"]) prefs[@"cydia legacy"] = [NSNumber numberWithBool:NO];
	if (![prefs objectForKey:@"zebra legacy"]) prefs[@"zebra legacy"] = [NSNumber numberWithBool:NO];
	if (![prefs objectForKey:@"installer legacy"]) prefs[@"installer legacy"] = [NSNumber numberWithBool:NO];
	if (![prefs objectForKey:@"sileo legacy"]) prefs[@"sileo legacy"] = [NSNumber numberWithBool:NO];

	[prefs writeToURL:[NSURL fileURLWithPath:preferencesPath] error:nil];
}

#import <objc/runtime.h>
#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook SearchController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *cydia = (NSNumber *)[prefs objectForKey:@"cydia"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"cydia hooking method"];
	if ((cydia && !cydia.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Cydia"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
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

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
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

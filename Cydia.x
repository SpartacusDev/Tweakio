/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/

#import <objc/runtime.h>
#import "Tweakio/TweakioViewController.h"
#import "HookHeaders.h"
#import "Settings/CydiaSettings.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook Cydia

- (void)loadData {
	%orig;

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *cydia = [prefs objectForKey:@"cydia"];
	if (cydia && ![cydia performSelector:@selector(boolValue)]) return;

	UIWindow *window = (UIWindow *)object_getIvar(self, class_getInstanceVariable([self class], "window_"));

	if (((UINavigationController *)(window.rootViewController)).viewControllers.count < 6) {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Cydia"]];
		NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
		UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
		UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
		[navController setTabBarItem:tweakioTabBarItem];

		NSMutableArray *controllers = [((UINavigationController *)window.rootViewController).viewControllers mutableCopy];

		[controllers addObject:navController];
		[(UINavigationController *)(window.rootViewController) setViewControllers:[controllers copy]];
	}
}

%end

%hook HomeController

- (void)viewDidLoad {
	%orig;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *cydia = [prefs objectForKey:@"cydia"];
	if (cydia && ![cydia performSelector:@selector(boolValue)]) return;
	UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(openSettings:)];
	[self.navigationItem setLeftBarButtonItem:settings];
}

%new - (void)openSettings:(UIBarButtonItem *)sender {
	[self.navigationController pushViewController:[[CydiaSettings alloc] initWithParent:self] animated:YES];
}

%end

%ctor {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesPath];
	if (![prefs objectForKey:@"Cydia API"]) prefs[@"Cydia API"] = 0;
	if (![prefs objectForKey:@"Zebra API"]) prefs[@"Zebra API"] = 0;
	if (![prefs objectForKey:@"Installer API"]) prefs[@"Installer API"] = 0;
	if (![prefs objectForKey:@"Sileo API"]) prefs[@"Sileo API"] = 0;
	[prefs writeToURL:[NSURL fileURLWithPath:preferencesPath] error:nil];
}

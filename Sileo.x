#import <objc/runtime.h>
#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook SileoAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig(application);

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *sileo = (NSNumber *)[prefs objectForKey:@"sileo"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"sileo hooking method"];
	if ((sileo && !sileo.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return;
	
    UIWindow *window = [self performSelector:@selector(window)];
	NSMutableArray<UINavigationController *> *controllers = [((UITabBarController *)window.rootViewController).viewControllers mutableCopy];

	TweakioViewController *tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Sileo"];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tweakio];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
    UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
    [navController setTabBarItem:tweakioTabBarItem];
    
    [controllers addObject:navController];
    [((UITabBarController *)window.rootViewController) setViewControllers:controllers];
    [self performSelector:@selector(setWindow:) withObject:window];
}

%end

%hook _TtC5Sileo25PackageListViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *sileo = (NSNumber *)[prefs objectForKey:@"sileo"];
    NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"sileo hooking method"];
	if ((sileo && !sileo.boolValue) || (hookingMethod && hookingMethod.intValue != 1) || (NSObject *)object_getIvar(self, class_getInstanceVariable(self.class, "repoContext")) || self.showWishlist) return;

    self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Sileo"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
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


%ctor {
    %init(SileoAppDelegate = NSClassFromString(@"Sileo.AppDelegate"));
}

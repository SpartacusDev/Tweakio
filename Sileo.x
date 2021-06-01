#import "Tweakio/TweakioViewController.h"
#import "HookHeaders.h"
#import "Settings/Settings.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook SileoAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig(application);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *sileo = [prefs objectForKey:@"sileo"];
	if (sileo && ![sileo performSelector:@selector(boolValue)]) return;

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

%hook SileoSettingsViewController

- (void)viewDidLoad {
	%orig;
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *sileo = [prefs objectForKey:@"sileo"];
	if (sileo && ![sileo performSelector:@selector(boolValue)]) return;
	UIBarButtonItem *tweakioSettings = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakioSettings:)];
	[[self performSelector:@selector(navigationItem)] performSelector:@selector(setLeftBarButtonItem:) withObject:tweakioSettings];
}

%new - (void)openTweakioSettings:(UIBarButtonItem *)sender {
	[(UINavigationController *)[self performSelector:@selector(navigationController)] pushViewController:[[Settings alloc] initWithPackageManager:@"Sileo" andBackgroundColor:((UIView *)[self performSelector:@selector(view)]).backgroundColor] animated:YES];
}

%end

%ctor {
    %init(SileoAppDelegate = NSClassFromString(@"Sileo.AppDelegate"), SileoSettingsViewController = NSClassFromString(@"Sileo.SettingsViewController"));
}

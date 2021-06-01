#import "Tweakio/TweakioViewController.h"
#import "Settings/Settings.h"
#import "HookHeaders.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook ATInstaller

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *installer = [prefs objectForKey:@"installer"];
	if (installer && ![installer performSelector:@selector(boolValue)]) return original;

	if (original) {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Installer"]];
		NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
		UIImage *icon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
		UITabBarItem *tweakioTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweakio" image:icon selectedImage:icon];
		[navController setTabBarItem:tweakioTabBarItem];
		
		NSMutableArray *controllers = [((UINavigationController *)self.window.rootViewController).viewControllers mutableCopy];

		[controllers addObject:navController];
		[((UINavigationController *)self.window.rootViewController) setViewControllers:controllers];
	}
	return original;
}

%end

%hook AccountPlistViewController

- (void)viewDidLoad {
	%orig;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
	NSObject *installer = [prefs objectForKey:@"installer"];
	if (installer && ![installer performSelector:@selector(boolValue)]) return;
	UIBarButtonItem *tweakioSettings = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakioSettings:)];
	[self.navigationItem setRightBarButtonItem:tweakioSettings];
}

%new - (void)openTweakioSettings:(UIBarButtonItem *)sender {
	[self.navigationController pushViewController:[[Settings alloc] initWithPackageManager:@"Installer" andBackgroundColor:self.view.backgroundColor] animated:YES];
}

%end

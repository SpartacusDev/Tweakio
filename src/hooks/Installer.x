#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#import "src/common.h"


%hook SearchViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *installer = (NSNumber *)[prefs objectForKey:@"installer"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"installer hooking method"];
	if ((installer && !installer.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Installer"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *animation = [prefs objectForKey:@"installer animation"];

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


%hook ATInstaller

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *installer = (NSNumber *)[prefs objectForKey:@"installer"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"installer hooking method"];
	if ((installer && !installer.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;


	if (original) {
		NSMutableArray<UINavigationController *> *controllers = [((UINavigationController *)self.window.rootViewController).viewControllers mutableCopy];

		TweakioViewController *tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Installer"];

		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tweakio];
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

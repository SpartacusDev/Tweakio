// #import <objc/runtime.h>
#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#import "Tweakio/TWMoreViewController.h"
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


%hook ZBSearchTableViewController

%property (nonatomic, strong) TweakioViewController *tweakio;

- (void)viewDidLoad {
    %orig;

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 1)) return;

	self.tweakio = [[TweakioViewController alloc] initWithPackageManager:@"Zebra"];

    UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Tweakio" style:UIBarButtonItemStylePlain target:self action:@selector(openTweakio:)];
    [self.navigationItem setLeftBarButtonItem:tweakio];
}

%new - (void)openTweakio:(UIBarButtonItem *)sender {
	[self.tweakio setBackgroundColor:self.view.backgroundColor];

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
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

// - (void)setupView {
// 	%orig;
// 	UISearchController *searchController = (UISearchController *)object_getIvar(self, class_getInstanceVariable([self class], "searchController"));
// 	if (searchController.searchBar.scopeButtonTitles.count == 3) {
// 		NSMutableArray<NSString *> *values = [searchController.searchBar.scopeButtonTitles mutableCopy];
// 		[values addObject:@"Tweakio"];
// 		searchController.searchBar.scopeButtonTitles = [values copy];
// 	}
// }

// - (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
// 	if (searchController.searchBar.selectedScopeButtonIndex == 3) {
// 		UISearchController *searchController2 = [[UISearchController alloc] initWithSearchResultsController:[[TweakioResultsViewController alloc] initWithNavigationController:self.navigationController andPackageManager:@"Zebra"]];
//         [searchController2 setDelegate:searchController.delegate];
//         [searchController2 setSearchResultsUpdater:searchController.searchResultsUpdater];
//         [searchController2.searchBar setDelegate:searchController.searchBar.delegate];
//         [searchController2.searchBar setTintColor:searchController.searchBar.tintColor];
//         [searchController2.searchBar setPlaceholder:searchController.searchBar.placeholder];
//         [searchController2.searchBar setScopeButtonTitles:searchController.searchBar.scopeButtonTitles];
//         [searchController2.searchBar setAutocapitalizationType:searchController.searchBar.autocapitalizationType];
// 		[searchController2.searchBar setSelectedScopeButtonIndex:3];
// 		[self.navigationItem setSearchController:searchController2];
// 		return;
// 	}
// 	searchController = (UISearchController *)object_getIvar(self, class_getInstanceVariable([self class], "searchController"));
// 	%orig(searchController);
// }

// - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
// 	UISearchController *searchController = self.navigationItem.searchController;
// 	if (searchController.searchBar.selectedScopeButtonIndex == 3) {
// 		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
// 			NSArray<Result *> *packages = nil;
// 			@try {
// 				packages = spartacusAPI(searchBar.text);
// 			} @catch (NSException *exception) {
// 				dispatch_async(dispatch_get_main_queue(), ^{
//                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:@"Please try again later or change API." preferredStyle:UIAlertControllerStyleAlert];
//                     [self presentViewController:alert animated:YES completion:^{
//                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                             [alert dismissViewControllerAnimated:YES completion:NULL];
//                         });
//                     }];
//                 });
// 			}
// 			if (packages) {
// 				[((TweakioResultsViewController *)searchController.searchResultsController) setupWithResults:packages andBackgroundColor:self.view.backgroundColor];
// 			}
// 		});
// 		return;
// 	}
// 	%orig(searchBar);
// }

%end

%group ZBiPhones

%hook ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL original = %orig(application, launchOptions);

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *zebra = (NSNumber *)[prefs objectForKey:@"zebra"];
	NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:@"zebra hooking method"];
	if ((zebra && !zebra.boolValue) || (hookingMethod && hookingMethod.intValue != 0)) return original;

	if (original) {
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

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
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
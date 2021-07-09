#import "TweakioRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <objc/runtime.h>
#define applicationPath @"/Applications/"

typedef enum PackageManager : int {
	Cydia = 0,
	Installer = 1,
	Sileo = 2,
	Tweakio = 3,
	Zebra = 4
} PackageManager;


// @interface PSSpecifier (Tweakio)

// @property (nonatomic, strong) NSNumber *visible;

// @end

// @implementation PSSpecifier (Tweakio)

// - (void)setVisible:(NSNumber *)visibility {
//     objc_setAssociatedObject(self, @selector(visible), visibility, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
// }

// - (NSNumber *)visible {
//     return objc_getAssociatedObject(self, @selector(visibile));
// }

// @end


@implementation TweakioRootListController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	for (int i = 0; i < 5; i++)
		if (![self isPackageManagerInstalled:i])
			[self removeSpecifier:[self specifierForID:[NSString stringWithFormat:@"%i", i]] animated:NO];
}

// - (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated {
// 	[super removeSpecifier:specifier animated:animated];
// 	[specifier setVisible:@NO];
// }

// - (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)secondSpecifier animated:(BOOL)animated {
// 	[super insertSpecifier:specifier afterSpecifier:secondSpecifier animated:animated];
// 	[specifier setVisible:@YES];
// }

- (BOOL)isPackageManagerInstalled:(PackageManager)packageManager {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isFolder = YES;

	if (packageManager == Sileo)
		return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo.app", applicationPath] isDirectory:&isFolder] || \
			   [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo~Beta.app", applicationPath] isDirectory:&isFolder];
	
	NSString *path;
	switch (packageManager) {
		case Cydia:
			path = @"Cydia.app";
			break;
		case Installer:
			path = @"Installer.app";
			break;
		case Tweakio:
			path = @"Tweakio.app";
			break;
		case Zebra:
			path = @"Zebra.app";
			break;
		default:
			NSLog(@"Achievement unlocked! How did we get here?");
			return NO;
	}
	return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", applicationPath, path] isDirectory:&isFolder];
}

- (void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/SpartacusDev/Tweakio"] options:@{} completionHandler:NULL];
}

- (void)joinDiscord {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/mZZhnRDGeg"] options:@{} completionHandler:NULL];
}

@end

#import "TweakioRootListController.h"

@implementation TweakioRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)openGithub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/SpartacusDev/Tweakio"] options:@{} completionHandler:NULL];
}

- (void)joinDiscord {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/mZZhnRDGeg"] options:@{} completionHandler:NULL];
}

@end

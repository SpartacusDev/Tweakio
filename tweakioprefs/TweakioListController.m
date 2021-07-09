#import "TweakioListController.h"


@interface TweakioListController ()

@end

@implementation TweakioListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Tweakio" target:self];
    }
    return _specifiers;
}

@end

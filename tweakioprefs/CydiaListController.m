#import "CydiaListController.h"


@interface CydiaListController ()

@end

@implementation CydiaListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Cydia" target:self];
    }
    return _specifiers;
}

@end

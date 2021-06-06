#import "SileoListController.h"


@interface SileoListController ()

@end

@implementation SileoListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Sileo" target:self];
    }
    return _specifiers;
}

@end

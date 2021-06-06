#import "ZebraListController.h"


@interface ZebraListController ()

@end

@implementation ZebraListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Zebra" target:self];
    }
    return _specifiers;
}

@end

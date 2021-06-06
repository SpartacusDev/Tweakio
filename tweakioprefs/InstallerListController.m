#import "InstallerListController.h"


@interface InstallerListController ()

@end

@implementation InstallerListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Installer" target:self];
    }
    return _specifiers;
}

@end

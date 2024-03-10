#import "TWPMListController.h"
#import <Preferences/PSSpecifier.h>
#import <CepheiUI/CepheiUI.h>
#import <objc/runtime.h>
#import "common.h"
#define CREATE_SPECIFIER(name, class) [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:class edit:nil]


@interface UIImage (AppIcon)

+ (instancetype)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(CGFloat)arg3;

@end

@interface PSSpecifier (setters)

- (void)setValues:(id)arg1 titles:(id)arg2;

@end

@interface TWPMListController () {
    NSString *_pm;
}

@end

@implementation TWPMListController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 120)];

    UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:[self packageManagerAppIdentifier] format:0 scale:[UIScreen mainScreen].scale];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];

    [iconView setFrame:CGRectMake(headerView.frame.size.width / 2 - 50, 10, 100, 100)];
    [iconView.layer setCornerRadius:20];
    [iconView.layer setMasksToBounds:YES];
    [headerView addSubview:iconView];

    if ([self respondsToSelector:@selector(tableView)]) {
		[self.tableView setTableHeaderView:headerView];
	} else {
		[[self valueForKey:@"_table"] setTableHeaderView:headerView];
	}

	[self reloadSpecifiers];
}

- (NSString *)packageManagerAppIdentifier {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isFolder = YES;

    if ([self->_pm isEqualToString:@"cydia"]) {
        return @"com.saurik.Cydia";
    }
    if ([self->_pm isEqualToString:@"installer"]) {
        return @"me.apptapp.installer";
    }
    if ([self->_pm isEqualToString:@"sileo"]) {
        return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo.app", APPLICATION_PATH] isDirectory:&(isFolder)] ? @"org.coolstar.SileoStore" :
               [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo-Beta.app", APPLICATION_PATH] isDirectory:&(isFolder)] ? @"org.coolstar.SileoBeta" : 
               [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo-Nightly.app", APPLICATION_PATH] isDirectory:&(isFolder)] ? @"org.coolstar.SileoNightly" : @"com.apple.Preferences";
    }
    if ([self->_pm isEqualToString:@"tweakio"]) {
        return @"com.spartacus.tweakioapp";
    }
    if ([self->_pm isEqualToString:@"zebra"]) {
        return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Zebra.app", APPLICATION_PATH] isDirectory:&(isFolder)] ? @"xyz.willy.Zebra" : 
               [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Zebra-Alpha.app", APPLICATION_PATH] isDirectory:&(isFolder)] ? @"xyz.willy.Zebralpha" : @"com.apple.Preferences";
    }
    return @"com.apple.Preferences";
}

- (void)setSpecifier:(PSSpecifier*)specifier {
	[super setSpecifier:specifier];
	self->_pm = [specifier.name lowercaseString];
	[self setTitle:CAPITALIZED_STRING([specifier.name lowercaseString])];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        PSSpecifier *enabled = CREATE_SPECIFIER(@"Enabled", PSSwitchCell);
        [enabled setProperty:[self->_pm lowercaseString] forKey:@"key"];
        [enabled setProperty:PREFERENCES_NAME forKey:@"defaults"];
        [enabled setProperty:@YES forKey:@"default"];
        [enabled setProperty:@"Enabled" forKey:@"label"];
        [enabled setProperty:@"enabled" forKey:@"id"];

        if ([[self->_pm lowercaseString] isEqualToString:@"tweakio"]) {
            _specifiers = [@[enabled] mutableCopy];
            return _specifiers;
        }

        PSSpecifier *implementationMethod = CREATE_SPECIFIER(@"Implementation Method", PSSegmentCell), *legacy = CREATE_SPECIFIER(@"Legacy Mode", PSSwitchCell), *animation = CREATE_SPECIFIER(@"Animation", PSSwitchCell);

        [implementationMethod setProperty:[[self->_pm lowercaseString] stringByAppendingString:@" hooking method"] forKey:@"key"];
        [implementationMethod setProperty:@"Tweakio Implementation" forKey:@"label"];
        [implementationMethod setProperty:PREFERENCES_NAME forKey:@"defaults"];
        [implementationMethod setProperty:@"0" forKey:@"default"];
        [implementationMethod setProperty:@"implementationMethod" forKey:@"id"];
        [implementationMethod setValues:@[@0, @1] titles:@[@"Tab Bar", @"Search Bar"]];

        [legacy setProperty:[[self->_pm lowercaseString] stringByAppendingString:@" legacy"] forKey:@"key"];
        [legacy setProperty:@"Legacy mode (current UI can be buggy on iOS 12)" forKey:@"label"];
        [legacy setProperty:PREFERENCES_NAME forKey:@"defaults"];
        [legacy setProperty:@NO forKey:@"default"];
        [legacy setProperty:@"legacy" forKey:@"id"];

        [animation setProperty:[[self->_pm lowercaseString] stringByAppendingString:@" animation"] forKey:@"key"];
        [animation setProperty:@"Animation (only for the Search Tab)" forKey:@"label"];
        [animation setProperty:PREFERENCES_NAME forKey:@"defaults"];
        [animation setProperty:@YES forKey:@"default"];
        [animation setProperty:@"animation" forKey:@"id"];

        _specifiers = [@[enabled, implementationMethod, legacy, animation] mutableCopy];
    }
    return _specifiers;
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];

    if ([[self readPreferenceValue:[self specifierForID:@"implementationMethod"]] intValue] != 1) {
        [self removeSpecifier:[self specifierForID:@"animation"] animated:NO];
    }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    [self reloadSpecifiers];
}

@end

#import "TweakioRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/CepheiPrefs.h>
#import <CepheiUI/CepheiUI.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "common.h"
#import "TWPMListController.h"
#import "TWApiManager.h"


typedef enum PackageManager : int {
	Cydia = 0,
	Installer = 1,
	Sileo = 2,
	Tweakio = 3,
	Zebra = 4
} PackageManager;

@interface TweakioRootListController () {
	NSArray<NSString *> *_packageManagers;
}

@end

@implementation TweakioRootListController

- (instancetype)init {
    self = [super init];

    if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor hb_colorWithPropertyListValue:@"#288028"];
		appearanceSettings.navigationBarTintColor = [UIColor hb_colorWithPropertyListValue:@"#0000ff"];
        appearanceSettings.navigationBarBackgroundColor = [UIColor hb_colorWithPropertyListValue:@"#a32c2c"];
        appearanceSettings.statusBarStyle = UIStatusBarStyleLightContent;
		appearanceSettings.tableViewCellTextColor = [UIColor hb_colorWithPropertyListValue:@"#288028"];
        self.hb_appearanceSettings = appearanceSettings;

		self->_packageManagers = @[@"cydia", @"installer", @"sileo", @"tweakio", @"zebra"];
    }

    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	[headerView setBackgroundColor:[UIColor hb_colorWithPropertyListValue:@"#000000"]];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	[imageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/TweakioPrefs.bundle/banner.png"]];
	[imageView setContentMode:UIViewContentModeScaleAspectFill];
	[imageView setClipsToBounds:YES];

	[headerView addSubview:imageView];

	imageView.translatesAutoresizingMaskIntoConstraints = NO;
	[imageView.topAnchor constraintEqualToAnchor:headerView.topAnchor].active = YES;
	[imageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor].active = YES;
	[imageView.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor].active = YES;
	[imageView.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor].active = YES;

	if ([self respondsToSelector:@selector(tableView)]) {
		[self.tableView setTableHeaderView:headerView];
	} else {
		[[self valueForKey:@"_table"] setTableHeaderView:headerView];
	}

	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray<PSSpecifier *> *_mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

		NSMutableArray<PSSpecifier *> *_pms = [
			@[[PSSpecifier preferenceSpecifierNamed:@"Package Managers" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]]
			mutableCopy
		];
		
		for (int i = 0; i < self->_packageManagers.count; i++) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:CAPITALIZED_STRING(self->_packageManagers[i]) target:self set:nil get:nil detail:TWPMListController.class cell:PSLinkCell edit:nil];
			[specifier setProperty:CAPITALIZED_STRING(self->_packageManagers[i]) forKey:@"label"];
			[specifier setProperty:self->_packageManagers[i] forKey:@"id"];
			[_pms addObject:specifier];
		}

		NSInteger index = 0;
		for (NSInteger i = 0; i < _mutableSpecifiers.count; i++) {
			if ([[_mutableSpecifiers[i] propertyForKey:@"id"] isEqualToString:@"contactCell"]) {
				index = ++i;
				break;
			}
		}
		[_mutableSpecifiers insertObjects:_pms atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, _pms.count)]];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:PLUGINS_PATH error:nil];
		NSArray<NSString *> *tweakioPlugins = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.dylib'"]];
		for (NSString *filePath in tweakioPlugins) {
			dlopen([[PLUGINS_PATH stringByAppendingString:filePath] UTF8String], RTLD_LAZY);
		}

		if ([[TWApiManager sharedInstance] options].count > 0) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"apis" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier setProperty:@"Searching API Options" forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
		}

		for (__kindof TWBaseApi *plugin in [[TWApiManager sharedInstance] options]) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:plugin.name target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
			[specifier setProperty:plugin.name forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
			
			specifier = [PSSpecifier preferenceSpecifierNamed:plugin.apiDescription target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
			[specifier setProperty:plugin.apiDescription forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
		}

		if ([[TWApiManager sharedInstance] ratingsOptions].count > 0) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"ratings apis" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier setProperty:@"Ratings API Options" forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
		}

		for (__kindof TWBaseRatingsApi *plugin in [[TWApiManager sharedInstance] ratingsOptions]) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:plugin.name target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
			[specifier setProperty:plugin.name forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
			
			specifier = [PSSpecifier preferenceSpecifierNamed:plugin.apiDescription target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
			[specifier setProperty:plugin.apiDescription forKey:@"label"];
			[_mutableSpecifiers addObject:specifier];
		}

		_specifiers = [_mutableSpecifiers copy];
	}
	return _specifiers;
}

- (UITableViewStyle)tableViewStyle {
	if (@available(iOS 13, *))
        return UITableViewStyleInsetGrouped;
	return [super tableViewStyle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil) {
		return cell;
	}

	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines = 0;

	UIFont *cellFont = cell.textLabel.font;
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
	CGSize labelSize = [cell.textLabel.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont, NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;

	[cell.textLabel setFrame:CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, labelSize.width, labelSize.height)];
	
    return cell;
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	for (int i = 0; i < self->_packageManagers.count; i++) {
		if (![self isPackageManagerInstalled:i]) {
			[self removeSpecifier:[self specifierForID:self->_packageManagers[i]] animated:NO];
		}
	}
}

- (BOOL)isPackageManagerInstalled:(PackageManager)packageManager {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isFolder = YES;
	
	NSString *path;
	switch (packageManager) {
		case Cydia:
			path = @"Cydia.app";
			break;
		case Installer:
			path = @"Installer.app";
			break;
		case Sileo:
			return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo.app", APPLICATION_PATH] isDirectory:&isFolder] || \
			   	   [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo-Beta.app", APPLICATION_PATH] isDirectory:&isFolder] || \
				   [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Sileo-Nightly.app", APPLICATION_PATH] isDirectory:&isFolder];
		case Tweakio:
			path = @"Tweakio.app";
			break;
		case Zebra:
			return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Zebra.app", APPLICATION_PATH] isDirectory:&isFolder] || \
			   	   [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@Zebra-Alpha.app", APPLICATION_PATH] isDirectory:&isFolder];
		default:
			LOG(@"TWEAKIO: Achievement unlocked! How did we get here?");
			return NO;
	}
	return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_PATH, path] isDirectory:&isFolder];
}

@end

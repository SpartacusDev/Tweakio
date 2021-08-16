#import "TweakioViewController.h"
#import "TweakViewController.h"
#import "TweakioResultsViewController.h"
#import "Settings.h"
#import "UITableViewCell+CydiaLike.h"
#import <Cephei/HBPreferences.h>
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


@interface TweakioViewController ()

@property (nonatomic, strong) NSArray<Result *> *results;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (assign) int preferredAPI;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation TweakioViewController

- (instancetype)initWithPackageManager:(NSString *)packageManager {
    self = [super init];
    if (self) {
        self.packageManager = packageManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self legacy]) {
        self.searchBar = [[UISearchBar alloc] init];
        [self.searchBar setDelegate:self];
        [self.searchBar setPlaceholder:@"Search Packages"];
        [self.navigationItem setTitleView:self.searchBar];
        [self setDefinesPresentationContext:YES];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
    } else {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:[[TweakioResultsViewController alloc] initWithNavigationController:self.navigationController andPackageManager:self.packageManager]];
        [self.searchController setObscuresBackgroundDuringPresentation:NO];
        [self.searchController setSearchResultsUpdater:self];
        [self.searchController.searchBar setDelegate:self];
        [self.searchController.searchBar setPlaceholder:@"Search Packages"];
        [self.navigationItem setSearchController:self.searchController];
        [self.navigationItem setHidesSearchBarWhenScrolling:NO];
        [self setTitle:@"Tweakio"];
    }

    self.results = [NSArray array];

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
    NSNumber *hookingMethod = (NSNumber *)[prefs objectForKey:[NSString stringWithFormat:@"%@ hooking method", self.packageManager.lowercaseString]];

    if (hookingMethod && hookingMethod.intValue == 1) {
        UIBarButtonItem *tweakio = [[UIBarButtonItem alloc] initWithTitle:@"Default" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        [self.navigationItem setLeftBarButtonItem:tweakio];
    }

    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(openSettings:)];
    [self.navigationItem setRightBarButtonItem:settings];

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (BOOL)legacy {
    __block HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
    NSNumber *legacy = (NSNumber *)[prefs objectForKey:[NSString stringWithFormat:@"%@ legacy", self.packageManager.lowercaseString]];
    if (legacy && legacy.boolValue) return YES;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (([fileManager fileExistsAtPath:@"/.bootstrapped"] || [fileManager fileExistsAtPath:@"/.installed_unc0ver"]) && !([prefs objectForKey:@"never show legacy note"] && ((NSNumber *)[prefs objectForKey:@"never show legacy note"]).boolValue)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Important!\nYou are using unc0ver/checkra1n" message:@"Please consider to activate Legacy Mode in preferences because the tweak may be buggy on these jailbreaks" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *neverAgain = [UIAlertAction actionWithTitle:@"Never show again" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [prefs setObject:@YES forKey:@"never show legacy note"];
        }];
        [alert addAction:ok];
        [alert addAction:neverAgain];
        [self presentViewController:alert animated:YES completion:NULL];
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.backgroundColor)
        [self.view setBackgroundColor:self.backgroundColor];

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
    self.preferredAPI = ((NSNumber *)[prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]]).intValue;

    if (self.activityIndicator) [self.activityIndicator removeFromSuperview];
    
    if (@available(iOS 13, *))
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    else
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.view addSubview:self.activityIndicator];

	[self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)goBack:(UIBarButtonItem *)sender {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
	NSNumber *animation = [prefs objectForKey:[NSString stringWithFormat:@"%@ animation", self.packageManager.lowercaseString]];

	if (animation && !animation.boolValue) {
		[self.navigationController popViewControllerAnimated:NO];
		return;
	}

    CATransition *transition = [[CATransition alloc] init];
    [transition setDuration:0.3];
    [transition setType:@"flip"];
    [transition setSubtype:kCATransitionFromRight];
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)openSettings:(UIBarButtonItem *)sender {
   [self.navigationController pushViewController:[[Settings alloc] initWithPackageManager:self.packageManager andBackgroundColor:self.view.backgroundColor] animated:YES];
}

- (void)search:(NSString *)query {
    switch (self.preferredAPI) {
        case 0:
            @try {
                HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
                BOOL fast = [prefs objectForKey:[NSString stringWithFormat:@"%@ Tweakio", self.packageManager]] ?
                            !((NSNumber *)([prefs objectForKey:[NSString stringWithFormat:@"%@ Tweakio", self.packageManager]])).boolValue :
                            YES;
                self.results = spartacusAPI(query, fast);
            } @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", exception] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                });
                self.results = [NSArray array];
            }
            break;
        case 1:
            @try {
                self.results = parcilityAPI(query);
            } @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", exception] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                });
                self.results = [NSArray array];
            }
            break;
        case 2:
            @try {
                self.results = canisterAPI(query);
            } @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", exception] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                });
                self.results = [NSArray array];
            }
            break;
        case 3:
            @try {
                self.results = iosrepoupdatesAPI(query);
            } @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", exception] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                });
                self.results = [NSArray array];
            }
            break;
        default:  // How did we get here?
            self.results = [NSArray array];
            break;
    }
    if (self.results.count != 0)
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    NSString *tweak = searchBar.text;
    if ([tweak isEqualToString:@""]) {
        self.results = [NSArray array];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return;
    }
    
    [self.activityIndicator startAnimating];
    [((TweakioResultsViewController *)self.searchController.searchResultsController) startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self search:tweak];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if ([self legacy])
                [self.tableView reloadData];
            else
                [((TweakioResultsViewController *)self.searchController.searchResultsController) setupWithResults:self.results];
        });
    });
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([searchController.searchBar.text isEqualToString:@""]) {
        self.results = [NSArray array];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchBar.text isEqualToString:@""]) {
        self.results = [NSArray array];
        if ([self legacy])
            [self.tableView reloadData];
        else {
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [((TweakioResultsViewController *)self.searchController.searchResultsController) clear];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self legacy]) {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return 0;
    }
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:self.results[indexPath.row].icon.class == NSNull.class ? nil : self.results[indexPath.row].icon];
    [icon setFrame:CGRectMake(cell.frame.origin.x + 10, cell.frame.size.height / 4, 20, 20)];
    [cell setIcon:icon];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(
                                                               icon.frame.origin.x + icon.frame.size.width * 1.5,
                                                               0,
                                                               cell.frame.size.width - icon.frame.origin.x + icon.frame.size.width,
                                                               cell.frame.size.height)];
    [title setText:[self.results[indexPath.row].name isEqual:@""] || self.results[indexPath.row].name.class == NSNull.class ? self.results[indexPath.row].package : self.results[indexPath.row].name];
    [title setTextAlignment:NSTextAlignmentLeft];
    [cell setTitle:title];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweakViewController *tweakViewController = [[TweakViewController alloc] initWithPackage:self.results[indexPath.row] andPackageManager:self.packageManager];
    [self.navigationController pushViewController:tweakViewController animated:YES];
}

@end

NSArray<Result *> *spartacusAPI(NSString *query, BOOL fast) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:
        fast ? 
        [NSString stringWithFormat:@"https://spartacusdev.herokuapp.com/api/search/%@", query]
        : [NSString stringWithFormat:@"https://spartacusdev.herokuapp.com/api/search_harder/%@", query]
    ];
    NSData *data = [NSData dataWithContentsOfURL:api];
    if (!data) {
        @throw [[NSException alloc] initWithName:@"APIException" reason:@"UNKNOWN" userInfo:nil];
        return [NSArray array];
    }
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];
        
        NSString *iconURL;
        if (((NSObject *)result[@"icon"]).class == NSNull.class || [result[@"icon"] isEqual:@""] || [result[@"icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"icon"]).class == NSNull.class) {
            iconURL = [NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconURL])
                iconURL = [NSString stringWithFormat:@"%@/unknown.png", bundlePath];
        }
        else
            iconURL = result[@"icon"];
        
        NSDictionary *data = @{
            @"name": result[@"name"],
            @"package": result[@"package"],
            @"version": result[@"version"],
            @"description": result[@"description"],
            @"author": result[@"author"] && ((NSObject *)result[@"author"]).class != NSNull.class ? result[@"author"] : @"UNKNOWN",
            @"icon": icon,
            @"filename": [NSURL URLWithString:result[@"filename"]],
            @"free": result[@"free"],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repo"]] andName:result[@"repo name"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] && ((NSObject *)result[@"depiction"]).class != NSNull.class ? [NSURL URLWithString:result[@"depiction"]] ?: [NSURL URLWithString:@""] : [NSURL URLWithString:@""],
            @"section": result[@"section"],
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}

NSArray<Result *> *parcilityAPI(NSString *query) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.parcility.co/db/search?q=%@", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    if (!data) {
        @throw [[NSException alloc] initWithName:@"APIException" reason:@"UNKNOWN" userInfo:nil];
        return [NSArray array];
    }
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"Section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"Section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if (((NSObject *)result[@"Icon"]).class == NSNull.class || [result[@"Icon"] isEqual:@""] || [result[@"Icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"Icon"]).class == NSNull.class) {
            iconURL = [NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"Section"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconURL])
                iconURL = [NSString stringWithFormat:@"%@/unknown.png", bundlePath];
        }
        else
            iconURL = result[@"Icon"];
        
        NSDictionary *data = @{
            @"name": result[@"Name"],
            @"package": result[@"Package"],
            @"version": result[@"Version"],
            @"description": result[@"Description"],
            @"author": result[@"Author"] && ((NSObject *)result[@"Author"]).class != NSNull.class ? result[@"Author"] : @"UNKNOWN",
            @"icon": icon,
            @"filename": [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", result[@"repo"][@"url"], ((NSArray *)result[@"builds"]).lastObject[@"Filename"]]],
            @"free": [NSNumber numberWithBool:[[results[@"Tag"] componentsSeparatedByString:@", "] containsObject:@"cydia::commercial"]],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repo"][@"url"]] andName:result[@"repo"][@"label"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"Depiction"] && ((NSObject *)result[@"Depiction"]).class != NSNull.class ? [NSURL URLWithString:result[@"Depiction"]] ?: [NSURL URLWithString:@""] : [NSURL URLWithString:@""],
            @"section": result[@"Section"],
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}

NSArray<Result *> *canisterAPI(NSString *query) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.canister.me/v1/community/packages/search?query=%@&searchFields=identifier,name,author,maintainer&responseFields=identifier,name,description,packageIcon,repository.uri,repository.name,author,latestVersion,depiction,section,price", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    if (!data) {
        @throw [[NSException alloc] initWithName:@"APIException" reason:@"UNKNOWN" userInfo:nil];
        return [NSArray array];
    }
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if (((NSObject *)result[@"packageIcon"]).class == NSNull.class || [result[@"packageIcon"] isEqual:@""] || [result[@"packageIcon"] hasPrefix:@"file://"] || ((NSObject *)results[@"packageIcon"]).class == NSNull.class) {
            iconURL = [NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconURL])
                iconURL = [NSString stringWithFormat:@"%@/unknown.png", bundlePath];
        }
        else
            iconURL = result[@"packageIcon"];

        NSDictionary *data = @{
            @"name": result[@"name"],
            @"package": result[@"identifier"],
            @"version": result[@"latestVersion"],
            @"description": result[@"description"],
            @"author": result[@"author"] && ((NSObject *)result[@"author"]).class != NSNull.class ? result[@"author"] : @"UNKNOWN",
            @"icon": icon,
            @"price": result[@"price"],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repository"][@"uri"]] andName:result[@"repository"][@"name"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] && ((NSObject *)result[@"depiction"]).class != NSNull.class ? [NSURL URLWithString:result[@"depiction"]] ?: [NSURL URLWithString:@""] : [NSURL URLWithString:@""],
            @"section": result[@"section"],
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}

NSArray<Result *> *iosrepoupdatesAPI(NSString *query) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.ios-repo-updates.com/1.0/search?s=%@", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    if (!data) {
        @throw [[NSException alloc] initWithName:@"APIException" reason:@"UNKNOWN" userInfo:nil];
        return [NSArray array];
    }
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"packages"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if (((NSObject *)result[@"packageIcon"]).class == NSNull.class || [result[@"packageIcon"] isEqual:@""] || [result[@"packageIcon"] hasPrefix:@"file://"] || ((NSObject *)results[@"packageIcon"]).class == NSNull.class) {
            iconURL = [NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconURL])
                iconURL = [NSString stringWithFormat:@"%@/unknown.png", bundlePath];
        }
        else
            iconURL = result[@"packageIcon"];

        NSDictionary *data = @{
            @"name": result[@"name"],
            @"package": result[@"identifier"],
            @"version": result[@"latestVersion"],
            @"description": result[@"description"],
            @"author": result[@"author"] && ((NSObject *)result[@"author"]).class != NSNull.class ? result[@"author"] : @"UNKNOWN",
            @"icon": icon,
            @"price": result[@"price"],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repository"][@"uri"]] andName:result[@"repository"][@"name"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] && ((NSObject *)result[@"depiction"]).class != NSNull.class ? [NSURL URLWithString:result[@"depiction"]] ?: [NSURL URLWithString:@""] : [NSURL URLWithString:@""],
            @"section": result[@"section"],
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}

#import "TweakioViewController.h"
#import "TweakViewController.h"
#import "TweakioResultsViewController.h"
#import "Settings.h"
#import "src/Extensions/UITableViewCell+CydiaLike.h"
#import <Cephei/HBPreferences.h>
#import "src/common.h"
#import "src/APIManagement/TWApiManager.h"


@interface TweakioViewController ()

@property (nonatomic, strong) NSArray<Result *> *results;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *preferredAPI;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) TWApiManager *apiManager;

@end

@implementation TweakioViewController

- (instancetype)initWithPackageManager:(NSString *)packageManager {
    self = [super init];
    if (self) {
        self.packageManager = packageManager;
        self.apiManager = [TWApiManager sharedInstance];
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

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
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
    __block HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
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

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
    self.preferredAPI = [prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]];
    if ([self.apiManager options].count > 0) {
        if (self.preferredAPI == nil || ![self.apiManager apiExistsForPrefsValue:self.preferredAPI]) {
            self.preferredAPI = [self.apiManager options][0].prefsValue;
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No APIs found" message:@"Make sure to have a Tweakio API plugin installed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
            self.preferredAPI = nil;
        }];
    }

    if (self.activityIndicator) [self.activityIndicator removeFromSuperview];
    
    if (@available(iOS 13, *))
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
#pragma clang diagnostic pop
    [self.activityIndicator setCenter:self.view.center];
    [self.view addSubview:self.activityIndicator];

	[self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)goBack:(UIBarButtonItem *)sender {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
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

- (void)search:(NSString *)query onError:(void (^)(NSError *))onError {
    NSError *err;
    [self.apiManager search:query error:&err api:self.preferredAPI onNoConfirmation:^(NSString *api) {
        [self.apiManager viewController:self apiTOSAndPrivacyPolicy:api ratings:NO completionHandler:^{
            [self search:query onError:onError];
        }];
    } onFinish:^(NSArray<Result *> *results, NSError *error) {
        if (error) {
            self.results = @[];
            onError(error);
        } else {
            self.results = [results copy];
        }

        if (self.results.count != 0) {
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if ([self legacy]) {
                [self.tableView reloadData];
            } else {
                [((TweakioResultsViewController *)self.searchController.searchResultsController) setupWithResults:self.results];
            }
        });
    }];

    if (err) {
        self.results = @[];
        onError(err);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if ([self legacy]) {
                [self.tableView reloadData];
            } else {
                [((TweakioResultsViewController *)self.searchController.searchResultsController) setupWithResults:self.results];
            }
        });
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.preferredAPI == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No APIs found" message:@"Make sure to have a Tweakio API plugin installed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:NULL];
        return;
    }
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
        [self search:tweak onError:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", error.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:NULL];
                    });
                }];
            });
        }];
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
        cell.frame.size.height
    )];

#if ROOTLESS
    if ([self.results[indexPath.row].architecture isEqualToString:@"iphoneos-arm"]) {
        [title setTextColor:[UIColor systemYellowColor]];
    } else if (![self.results[indexPath.row].architecture isEqualToString:@"iphoneos-arm64"]) {
        [title setTextColor:[UIColor systemRedColor]];
    }
#else
    if ([self.results[indexPath.row].architecture isEqualToString:@"iphoneos-arm64"]) {
        [title setTextColor:[UIColor systemYellowColor]];
    } else if (![self.results[indexPath.row].architecture isEqualToString:@"iphoneos-arm"]) {
        [title setTextColor:[UIColor systemRedColor]];
    }
#endif

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

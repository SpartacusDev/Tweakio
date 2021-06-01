#import "TweakioViewController.h"
#import "TweakViewController.h"
#import "UITableViewCell+CydiaLike.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


@interface TweakioViewController ()

@property (nonatomic, strong) NSArray<Result *> *results;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (assign) int preferredAPI;

@end

@implementation TweakioViewController

- (instancetype)initWithPackageManager:(NSString *)packageManager {
    self = [super init];
    if (self) {
        self.packageManager = packageManager;

        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesPath];
        self.preferredAPI = ((NSNumber *)prefs[[NSString stringWithFormat:@"%@ API", self.packageManager]]).intValue;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar setDelegate:self];
    [self.searchBar setPlaceholder:@"Search Packages"];
    [self.navigationItem setTitleView:self.searchBar];
    [self setDefinesPresentationContext:YES];
    
    self.results = [NSArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)search:(NSString *)query {
    switch (self.preferredAPI) {
        case 0:
            self.results = spartacusAPI(query);
            break;
        case 1:
            self.results = parcilityAPI(query);
            break;
        case 2:
            self.results = canisterAPI(query);
            break;
        default:  // How did we get here?
            self.results = [NSArray array];
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditing:nil];
    NSString *tweak = searchBar.text;
    if ([tweak isEqualToString:@""]) {
        self.results = [NSArray array];
        [self.tableView reloadData];
        return;
    }
    UIAlertController *loading = [UIAlertController alertControllerWithTitle:@"Searching..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self performSelector:@selector(dismissPopup) withObject:nil afterDelay:2.0];

    [self presentViewController:loading animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self search:tweak];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissPopup];
            });
        });
    }];
}

- (void)dismissPopup {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    UIBarButtonItem *end = [[UIBarButtonItem alloc] initWithTitle:@"Return" style:UIBarButtonItemStyleDone target:self action:@selector(endEditing:)];
    [self.navigationItem setRightBarButtonItem:end];
}

- (void)endEditing:(nullable UIBarButtonItem *)sender {
    [self.searchBar endEditing:YES];
    [self.navigationItem setRightBarButtonItem:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *tweak = searchBar.text;
    if ([tweak isEqualToString:@""]) {
        self.results = [NSArray array];
        [self.tableView reloadData];
        return;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"   forIndexPath:indexPath];

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
    [title setText:self.results[indexPath.row].name];
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

NSArray<Result *> *spartacusAPI(NSString *query) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://spartacusdev.herokuapp.com/api/search/%@", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if ([result[@"icon"] isEqualToString:@""] || [result[@"icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"icon"]).class == NSNull.class) {
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
            @"author": result[@"author"],
            @"icon": icon,
            @"filename": [NSURL URLWithString:result[@"filename"]],
            @"free": result[@"free"],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repo"]] andName:result[@"repo name"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] ? [NSURL URLWithString:result[@"depiction"]] : [NSURL URLWithString:@""],
            @"section": result[@"section"]
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
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"Section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"Section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if ([result[@"Icon"] isEqualToString:@""] || [result[@"Icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"Icon"]).class == NSNull.class) {
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
            @"author": result[@"Author"],
            @"icon": icon,
            @"filename": [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", result[@"repo"][@"url"], ((NSArray *)result[@"builds"]).lastObject[@"Filename"]]],
            @"free": [NSNumber numberWithBool:[[results[@"Tags"] componentsSeparatedByString:@", "] containsObject:@"cydia::commercial"]],
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repo"][@"url"]] andName:result[@"repo"][@"label"]],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"Depiction"] ? [NSURL URLWithString:result[@"Depiction"]] : [NSURL URLWithString:@""],
            @"section": result[@"Section"]
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}

NSArray<Result *> *canisterAPI(NSString *query) {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.canister.me/v1/community/packages/search?query=%@&searchFields=id,name,author,maintainer&responseFields=id,name,description,icon,repositoryURI,author,latestVersion,depiction,section", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSObject *icon;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]])
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]]]];
        else
            icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/unknown.png", bundlePath]]];

        NSString *iconURL;
        if ([result[@"icon"] isEqualToString:@""] || [result[@"icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"icon"]).class == NSNull.class) {
            iconURL = [NSString stringWithFormat:@"%@/%@.png", bundlePath, result[@"section"]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:iconURL])
                iconURL = [NSString stringWithFormat:@"%@/unknown.png", bundlePath];
        }
        else
            iconURL = result[@"icon"];

        NSDictionary *data = @{
            @"name": result[@"name"],
            @"version": result[@"latestVersion"],
            @"description": result[@"description"],
            @"author": result[@"author"],
            @"icon": icon,
            @"repo": [[Repo alloc] initWithURL:[NSURL URLWithString:result[@"repositoryURI"]] andName:@"UNKNOWN"],
            @"icon url": [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] ? [NSURL URLWithString:result[@"depiction"]] : [NSURL URLWithString:@""],
            @"section": result[@"section"]
        };
        [resultsArray addObject:[[Result alloc] initWithDictionary:data]];
    }
    return [resultsArray copy];
}
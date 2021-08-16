#import <objc/runtime.h>
#import "TweakioResultsViewController.h"
#import "UITableViewCell+CydiaLike.h"
#import "TweakViewController.h"


@interface UITableView (SearchResults)

@property (nonatomic, strong) NSNumber *hasBeenSetup;

@end

@implementation UITableView (SearchResults)

- (void)setHasBeenSetup:(NSNumber *)hasBeenSetup {
    static UIActivityIndicatorView *activityIndicatorView = nil;
    if (!activityIndicatorView) {
        if (@available(iOS 13, *))
            activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        else
            activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView setCenter:self.center];
        [self addSubview:activityIndicatorView];

        [activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    }
    if (!hasBeenSetup.boolValue) [activityIndicatorView startAnimating];
    else [activityIndicatorView stopAnimating];
    objc_setAssociatedObject(self, @selector(hasBeenSetup), hasBeenSetup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)hasBeenSetup {
    return objc_getAssociatedObject(self, @selector(icon));
}

@end


@interface TweakioResultsViewController ()

// @property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readwrite) UINavigationController *navigationController;

@end

@implementation TweakioResultsViewController

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController andPackageManager:(NSString *)packageManager {
    self = [super init];
    if (self) {
        self.navigationController = navigationController;
        self.packageManager = packageManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.results = [NSArray array];
    
    // self.tableView = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStylePlain];
    // [self.tableView setDelegate:self];
    // [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.results = [NSArray array];
    [self.tableView reloadData];
    
    // [self.tableView removeFromSuperview];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)startAnimating {
    [self.tableView setHasBeenSetup:@NO];
}

- (void)setupWithResults:(NSArray<Result *> *)results {
    self.results = results;
    // [self.view setBackgroundColor:backgroundColor];
    // [self.view addSubview:self.tableView];
    [self.tableView setHasBeenSetup:@YES];
    [self.tableView reloadData];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)clear {
    self.results = [NSArray array];
    [self.tableView reloadData];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

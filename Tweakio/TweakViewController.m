#import <WebKit/WebKit.h>
#import <sys/utsname.h>
#import "TweakViewController.h"


@interface TweakViewController ()

// @property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Result *package;
@property (nonatomic, strong) NSArray *information;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TweakViewController

- (instancetype)initWithPackage:(Result *)package andPackageManager:(NSString *)packageManager {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.package = package;
        self.packageManager = packageManager;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *relevantInformation = [NSMutableArray array];
    
    [relevantInformation addObject:[NSString stringWithFormat:@"Package ID: %@", self.package.package]];
    [relevantInformation addObject:[NSString stringWithFormat:@"Author: %@", self.package.author]];
    [relevantInformation addObject:[NSString stringWithFormat:@"Version: %@", self.package.version]];
    if (self.package.price != nil)
        [relevantInformation addObject:self.package.price];
    else
        [relevantInformation addObject:self.package.free ? @"Free" : @"Paid"];
    [relevantInformation addObject:self.package.repo.url.absoluteString];
    if ([self.packageManager isEqualToString:@"Tweakio"]) {
        [relevantInformation addObject:@"Add repo to Cydia"];
        [relevantInformation addObject:@"Add repo to Zebra"];
        [relevantInformation addObject:@"Add repo to Installer"];
        [relevantInformation addObject:@"Add repo to Sileo"];
    } else
        [relevantInformation addObject:[NSString stringWithFormat:@"Add repo to %@", self.packageManager]];
    [relevantInformation addObject:self.package.packageDescription];
    
    self.information = [relevantInformation copy];
    
    if (self.package.free) {
        UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target:self action:@selector(download:)];
        [self.navigationItem setRightBarButtonItem:download];
    }

    // self.tableView = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStyleGrouped];
    // [self.tableView setDelegate:self];
    // [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    if (![self.package.depiction.absoluteString isEqualToString:@""])
        [self createDepiction];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height / 4)];
    [self.tableView setTableHeaderView:header];

    UIImageView *icon = [[UIImageView alloc] initWithImage:self.package.icon.class == NSNull.class ? nil : self.package.icon];
    [icon setFrame:CGRectMake(header.frame.size.width / 2 - 50, 10, 100, 100)];
    [icon.layer setCornerRadius:20];
    [icon.layer setMasksToBounds:YES];
    [header addSubview:icon];

//    [icon.widthAnchor constraintEqualToConstant:icon.frame.size.width].active = YES;
//    [icon.heightAnchor constraintEqualToConstant:icon.frame.size.height].active = YES;
//    [icon.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
//    [icon.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:25].active = YES;;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.package.iconURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [icon setImage:[UIImage imageWithData:imageData]];
        });
    });
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, header.frame.size.height - 20, header.frame.size.width, 20)];
    [name setText:self.package.name.class == NSNull.class ? self.package.package : self.package.name];
    [name setTextAlignment:NSTextAlignmentCenter];
    [header addSubview:name];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationDidChange:(NSNotification *)sender {
    UIView *header = self.tableView.tableHeaderView;
    UIImageView *icon = header.subviews.firstObject.class == UIImageView.class ? header.subviews.firstObject : header.subviews.lastObject;
    UILabel *label = header.subviews.firstObject.class == UILabel.class ? header.subviews.firstObject : header.subviews.lastObject;
    [icon setFrame:CGRectMake(header.frame.size.width / 2 - 50, 10, 100, 100)];
    [label setFrame:CGRectMake(0, header.frame.size.height - 20, header.frame.size.width, 20)];
}

- (void)createDepiction {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAudio;
    configuration.applicationNameForUserAgent = @"Cydia/1.1.32";

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, UIScreen.mainScreen.bounds.size.height) configuration:configuration];
    self.webView.scrollView.scrollEnabled = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.package.depiction];

        NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        // For the X-Machine header
        struct utsname systemInfo;
        uname(&systemInfo);

        [request setValue:udid forHTTPHeaderField:@"X-Cydia-ID"];
        [request setValue:@"Cydia/1.1.32" forHTTPHeaderField:@"User-Agent"];
        [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
        [request setValue:udid forHTTPHeaderField:@"X-Unique-ID"];
        [request setValue:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] forHTTPHeaderField:@"X-Machine"];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView loadRequest:request];
            [self.tableView setTableFooterView:self.webView];

            // [self.webView.widthAnchor constraintEqualToConstant:self.webView.frame.size.width].active = YES;
            // [self.webView.heightAnchor constraintEqualToConstant:self.webView.frame.size.height].active = YES;
        });
    });
}

- (void)download:(UIButton *)sender {
    __block UIAlertController *popup = [UIAlertController alertControllerWithTitle:@"Downloading..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:popup animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *packageData = [[NSData alloc] initWithContentsOfURL:self.package.downloadURL];
            [packageData writeToFile:[NSString stringWithFormat:@"/var/mobile/Downloads/%@.deb", self.package.package] atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:NULL];
                [popup setTitle:@"Done!"];
                [popup setMessage:[NSString stringWithFormat:@"Downloaded to: /var/mobile/Downloads/%@.deb", self.package.package]];
                [popup addAction:ok];
            });
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.information.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;

        UIFont *cellFont = cell.textLabel.font;
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        CGSize labelSize = [self.package.packageDescription boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont, NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;
        
        [cell.textLabel setFrame:CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, labelSize.width, labelSize.height)];
        [cell.textLabel setText:self.package.packageDescription];
    } else {
        [cell.textLabel setText:self.information[indexPath.row]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.information.count == 7) {
        if (indexPath.row != [self tableView:self.tableView numberOfRowsInSection:indexPath.section] - 2) return;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:self.packageManager]] options:@{} completionHandler:NULL];
        return;
    }
    switch (indexPath.row) {
        case 5:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Cydia"]] options:@{} completionHandler:NULL];
            break;
        case 6:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Zebra"]] options:@{} completionHandler:NULL];
            break;
        case 7:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Installer"]] options:@{} completionHandler:NULL];
            break;
        case 8:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Sileo"]] options:@{} completionHandler:NULL];
    }
}

@end

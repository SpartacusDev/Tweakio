#import <WebKit/WebKit.h>
#import <sys/utsname.h>
#import "TweakViewController.h"
#import "src/APIManagement/TWApiManager.h"
#import "src/common.h"
#import <Cephei/HBPreferences.h>
#import "TWReviewViewController.h"
#import <math.h>

@interface TweakViewController ()

@property (nonatomic, strong) Result *package;
@property (nonatomic, strong) NSArray *information;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TweakViewController

- (instancetype)initWithPackage:(Result *)package andPackageManager:(NSString *)packageManager {
    if (@available(iOS 13, *))
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    else 
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
    [relevantInformation addObject:[NSString stringWithFormat:@"Architecture: %@", self.package.architecture]];
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
    
    if (self.package.free && self.package.downloadURL) {
        UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target:self action:@selector(download:)];
        [self.navigationItem setRightBarButtonItem:download];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    if (![self.package.depiction.absoluteString isEqualToString:@""])
        [self createDepiction];

    [self packageRating];
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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.package.iconURL.class == NSNull.class) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [icon setImage:self.package.icon];
            });
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:self.package.iconURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [icon setImage:[UIImage imageWithData:imageData]];
            });
        }
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

- (void)packageRating {
    TWApiManager *apiManager = [TWApiManager sharedInstance];
    if ([apiManager ratingsOptions].count == 0) {
        return;
    }

    if (self.package.rating != -1) {
        NSString *ratingString = @"Rating: ";

        if (round(self.package.rating) == 0) {
            ratingString = [ratingString stringByAppendingString:@"☆☆☆☆☆"];
        } else {
            for (int i = 0; i < 5; i++) {
                ratingString = [ratingString stringByAppendingString:round(self.package.rating) >= i ? @"★" : @"☆"];
            }
        }
        ratingString = [NSString stringWithFormat:@"%@%.1f ", ratingString, self.package.rating];

        NSMutableArray<NSString *> *_mutableInformation = [self.information mutableCopy];
        [_mutableInformation insertObject:ratingString atIndex:0];
        self.information = [_mutableInformation copy];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return;
    }

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *err;
        [apiManager ratingsSearch:self.package error:&err api:[prefs objectForKey:[NSString stringWithFormat:@"%@ ratings API", self.packageManager] default:[apiManager ratingsOptions][0].prefsValue] onNoConfirmation:^(NSString *api) {
            [apiManager viewController:self apiTOSAndPrivacyPolicy:api ratings:YES completionHandler:^{
                [self packageRating];
            }];
        } onFinish:^(float rating, NSArray<TWReview *> *reviews, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred while getting package rating and reviews" message:[NSString stringWithFormat:@"Please try again later or change ratings API. Error message: %@", error.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                });
                return;
            }

            self.package.rating = rating;
            self.package.reviews = reviews;

            NSString *ratingString = @"Rating: ";

            if (round(rating) == 0) {
                ratingString = [ratingString stringByAppendingString:@"☆☆☆☆☆"];
            } else {
                for (int i = 0; i < 5; i++) {
                    ratingString = [ratingString stringByAppendingString:round(rating) >= i ? @"★" : @"☆"];
                }
            }
            ratingString = [NSString stringWithFormat:@"%@ %.1f ", ratingString, rating];

            NSMutableArray<NSString *> *_mutableInformation = [self.information mutableCopy];
            [_mutableInformation insertObject:ratingString atIndex:0];
            self.information = [_mutableInformation copy];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];

        if (err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error has occurred while searching for reviews" message:[NSString stringWithFormat:@"Please try again later or change API. Error message: %@", err.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:NULL];
                    });
                }];
            });
        }
    });
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
        });
    });
}

- (void)download:(UIButton *)sender {
    __block UIAlertController *popup = [UIAlertController alertControllerWithTitle:@"Downloading..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:popup animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSData *packageData = [[NSData alloc] initWithContentsOfURL:self.package.downloadURL];
            NSURL *fileURL = [fileManager.temporaryDirectory URLByAppendingPathComponent:[self.package.package stringByAppendingString:@".deb"]];

            NSError *error;
            [packageData writeToFile:fileURL.path options:NSDataWritingAtomic error:&error];

            dispatch_async(dispatch_get_main_queue(), ^{
                [popup dismissViewControllerAnimated:YES completion:NULL];

                if (!error) {
                    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                    [self presentViewController:activityViewController animated:YES completion:NULL];
                } else {
                    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"An error has occurred" message:error.description preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:errorAlert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [errorAlert dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }];
                }
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

    if ([cell.textLabel.text hasPrefix:@"Architecture: "]) {
#if ROOTLESS
        if ([self.package.architecture isEqualToString:@"iphoneos-arm"]) {
            [cell.textLabel setTextColor:[UIColor systemYellowColor]];
        } else if (![self.package.architecture isEqualToString:@"iphoneos-arm64"]) {
            [cell.textLabel setTextColor:[UIColor systemRedColor]];
        }
#else
        if ([self.package.architecture isEqualToString:@"iphoneos-arm64"]) {
            [cell.textLabel setTextColor:[UIColor systemYellowColor]];
        } else if (![self.package.architecture isEqualToString:@"iphoneos-arm"]) {
            [cell.textLabel setTextColor:[UIColor systemRedColor]];
        }
#endif
    } else if (@available(iOS 13, *)) {
        [cell.textLabel setTextColor:[UIColor labelColor]];
    } else {
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && [self.information[0] hasPrefix:@"Rating: "]) {
        [self presentViewController:[[TWReviewViewController alloc] initWithReviews:self.package.reviews] animated:YES completion:NULL];
        return;
    }

    if (self.information.count == 8 || self.information.count == 9) {
        if (indexPath.row != [self tableView:self.tableView numberOfRowsInSection:indexPath.section] - 2) return;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:self.packageManager]] options:@{} completionHandler:NULL];
        return;
    }

    if ([self.information[indexPath.row] isEqualToString:@"Add repo to Cydia"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Cydia"]] options:@{} completionHandler:NULL];
        return;
    }
    if ([self.information[indexPath.row] isEqualToString:@"Add repo to Zebra"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Cydia"]] options:@{} completionHandler:NULL];
        return;
    }
    if ([self.information[indexPath.row] isEqualToString:@"Add repo to Installer"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Cydia"]] options:@{} completionHandler:NULL];
        return;
    }
    if ([self.information[indexPath.row] isEqualToString:@"Add repo to Sileo"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.package.repo addTo:@"Cydia"]] options:@{} completionHandler:NULL];
        return;
    }
}

@end

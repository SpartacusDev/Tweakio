#import "Result.h"
#import "src/common.h"


@interface Result ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *package;
@property (nonatomic, strong, readwrite) NSString *version;
@property (nonatomic, strong, readwrite) NSString *packageDescription;
@property (nonatomic, strong, readwrite) NSString *author;
@property (nonatomic, strong, readwrite) UIImage *icon;
@property (nonatomic, strong, readwrite) NSURL *downloadURL;
@property (assign, readwrite) BOOL free;
@property (nonatomic, strong, readwrite) Repo *repo;
@property (nonatomic, strong, readwrite) NSURL *iconURL;
@property (nonatomic, strong, readwrite) NSURL *depiction;
@property (nonatomic, strong, readwrite) NSString *section;
@property (nonatomic, strong, readwrite) NSString *price;
@property (nonatomic, strong, readwrite) NSString *architecture;

@end

@implementation Result

- (instancetype)initWithDictionary:(NSDictionary *)dataDictionary {
    self = [super init];
    if (self) {
        self.name = dataDictionary[@"name"];
        self.package = [dataDictionary objectForKey:@"package"] ?: @"UNKNOWN";
        self.version = dataDictionary[@"version"];
        self.packageDescription = dataDictionary[@"description"];
        self.author = dataDictionary[@"author"];
        self.section = dataDictionary[@"section"];
        self.icon = nil;

        NSString *pm = getPackageManager();
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([pm isEqualToString:@"Cydia"]) {
            NSString *imagePath = [NSString stringWithFormat:@"/Applications/Cydia.app/Sections/%@", self.section];
            if ([fm fileExistsAtPath:imagePath]) {
                self.icon = [[UIImage alloc] initWithContentsOfFile:imagePath];
            }
        } else if ([pm isEqualToString:@"Installer"]) {
            self.icon = [UIImage imageNamed:[NSString stringWithFormat:@"Categories/%@", self.section]];
        } else if ([pm isEqualToString:@"Sileo"]) {
            NSString *section = [self.section lowercaseString];
            if ([section isEqualToString:@"tweaks"]) {
                section = @"tweak";
            }
            self.icon = [UIImage imageNamed:[NSString stringWithFormat:@"Category_%@", section]];
        } else if ([pm isEqualToString:@"Zebra"]) {
            self.icon = [NSClassFromString(@"PLSource") performSelector:@selector(imageForSection:) withObject:self.section];
            if (self.icon == nil) {
                self.icon = [UIImage imageNamed:self.section];
            }
            if (self.icon == nil) {
                self.icon = [UIImage imageNamed:@"Unknown"];
            }
        } else {
            self.icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWPackage.png", BUNDLE_PATH]]];
        }
        if (self.icon == nil) {
            self.icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWPackage.png", BUNDLE_PATH]]];
        }

        self.downloadURL = [dataDictionary objectForKey:@"filename"];
        if ([dataDictionary objectForKey:@"free"]) {
            self.free = [dataDictionary objectForKey:@"free"] ? [dataDictionary[@"free"] performSelector:@selector(boolValue)] : NO;
            self.price = nil;
        } else {
            if ([dataDictionary[@"price"] isEqualToString:@"Free"]) {
                self.free = YES;
                self.price = nil;
            } else {
                self.free = NO;
                self.price = dataDictionary[@"price"];
            }
        }
        self.repo = dataDictionary[@"repo"];
        self.iconURL = dataDictionary[@"icon url"];
        self.depiction = dataDictionary[@"depiction"];
        self.architecture = dataDictionary[@"architecture"];
        self.rating = [dataDictionary objectForKey:@"rating"] ? [dataDictionary[@"rating"] floatValue] : -1;
    }
    return self;
}

@end
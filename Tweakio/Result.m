#import "Result.h"


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
        self.icon = dataDictionary[@"icon"];
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
        self.section = dataDictionary[@"section"];
    }
    return self;
}

@end
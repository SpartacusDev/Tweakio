#import "Repo.h"


@interface Repo ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSString *name;

@end


@implementation Repo

- (instancetype)initWithURL:(NSURL *)url andName:(NSString *)name {
    self = [super init];
    if (self) {
        self.url = url;
        self.name = name;
    }
    return self;
}

- (NSString *)addTo:(NSString *)packageManager {
    if ([[packageManager lowercaseString] isEqualToString:@"cydia"]) return [NSString stringWithFormat:@"cydia://url/https://cydia.saurik.com/api/share#?source=%@", self.url.absoluteString];
    if ([[packageManager lowercaseString] isEqualToString:@"zebra"]) return [NSString stringWithFormat:@"zbra://sources/add/%@", self.url.absoluteString];
    if ([[packageManager lowercaseString] isEqualToString:@"installer"]) return [NSString stringWithFormat:@"installer://add/%@", self.url.absoluteString];
    if ([[packageManager lowercaseString] isEqualToString:@"sileo"]) return [NSString stringWithFormat:@"sileo://source/%@", self.url.absoluteString];
    [NSException raise:@"Not a valid package manager name" format:@"Package manager %@ is invalid. How did you even manage to do that?", packageManager];
    return @"";
}

- (NSArray<NSString *> *)arrayAddTo {
    return @[
        [NSString stringWithFormat:@"cydia://url/https://cydia.saurik.com/api/share#?source=%@", self.url.absoluteString],
        [NSString stringWithFormat:@"zbra://sources/add/%@", self.url.absoluteString],
        [NSString stringWithFormat:@"installer://add/%@", self.url.absoluteString],
        [NSString stringWithFormat:@"sileo://source/%@", self.url.absoluteString]
    ];
}

@end

#import "TWContact.h"
#import <Preferences/PSSpecifier.h>


@interface TWContact ()

@end


@implementation TWContact

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.accessoryView = [[UIImageView alloc] init];
        if (self.specifier.properties[@"id"] == nil) {
            self.specifier.properties[@"id"] = @"contactCell";
        }
    }
    return self;
}

+ (NSURL *)_urlForUsername:(NSString *)username userID:(NSString *)userID {
    return [NSURL URLWithString:@"https://discord.gg/mZZhnRDGeg"];
}

@end
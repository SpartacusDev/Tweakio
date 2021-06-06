#import <UIKit/UIKit.h>
#import "Repo.h"


@interface Result : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *package;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *packageDescription;
@property (nonatomic, strong, readonly) NSString *author;
@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) NSURL *downloadURL;
@property (assign, readonly) BOOL free;
@property (nonatomic, strong, readonly) Repo *repo;
@property (nonatomic, strong, readonly) NSURL *iconURL;
@property (nonatomic, strong, readonly) NSURL *depiction;
@property (nonatomic, strong, readonly) NSString *section;
@property (nonatomic, strong, readonly) NSString *price;

- (instancetype)initWithDictionary:(NSDictionary *)dataDictionary;

@end
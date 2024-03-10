#import "TWReview.h"


@interface TWReview ()

@property (nonatomic, strong, readwrite) NSString *author;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *content;
@property (assign, readwrite) int rating;

@end

@implementation TWReview

- (instancetype)initWithAuthor:(NSString *)author title:(NSString *)title content:(NSString *)content rating:(int)rating {
    self = [super init];
    if (self) {
        self.author = author;
        self.title = title;
        self.content = content;
        self.rating = rating;
    }
    return self;
}

@end
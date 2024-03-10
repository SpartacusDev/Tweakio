#import <Foundation/Foundation.h>


@interface TWReview : NSObject

@property (nonatomic, strong, readonly, nullable) NSString *title;
@property (nonatomic, strong, readonly, nullable) NSString *author;
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong, readonly) NSString *content;
@property (assign, readonly) int rating;
NS_ASSUME_NONNULL_END

- (instancetype _Nullable)initWithAuthor:(NSString * _Nonnull)author title:(NSString * _Nullable)title content:(NSString * _Nonnull)content rating:(int)rating;

@end
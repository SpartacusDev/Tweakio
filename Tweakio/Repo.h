#import <Foundation/Foundation.h>


@interface Repo : NSObject

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *name;

- (instancetype)initWithURL:(NSURL *)url andName:(NSString *)name;
- (NSString *)addTo:(NSString *)packageManager;
- (NSArray<NSString *> *)arrayAddTo;

@end
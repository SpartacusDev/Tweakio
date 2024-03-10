#import "TWApiManager.h"
#import <objc/runtime.h>


@implementation TWBaseApi

@end

@implementation TWBaseRatingsApi

@end

@interface TWApiManager ()

@end

@implementation TWApiManager

+ (instancetype)sharedInstance {
    static TWApiManager *sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (NSArray<__kindof TWBaseApi *> *)options {
    static NSMutableArray<__kindof TWBaseApi *> *apiHandlers = nil;
    static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
        apiHandlers = [[NSMutableArray alloc] init];
		int numClasses;
        Class *classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 ) {
            classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                if (class_getSuperclass(classes[i]) == [TWBaseApi class]) {
                    [apiHandlers addObject:[[classes[i] alloc] init]];
                }
            }
            free(classes);
        }
	});
    return [apiHandlers copy];
}

- (NSArray<__kindof TWBaseRatingsApi *> *)ratingsOptions {
    static NSMutableArray<__kindof TWBaseApi *> *apiHandlers = nil;
    static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
        apiHandlers = [[NSMutableArray alloc] init];
		int numClasses;
        Class *classes = NULL;
        
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 ) {
            classes = (Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                if (class_getSuperclass(classes[i]) == [TWBaseRatingsApi class]) {
                    [apiHandlers addObject:[[classes[i] alloc] init]];
                }
            }
            free(classes);
        }
	});
    return [apiHandlers copy];
}

@end
#import <UIKit/UIKit.h>


@interface Settings : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

- (instancetype)initWithPackageManager:(NSString *)packageManager andBackgroundColor:(UIColor *)backgroundColor;

@end

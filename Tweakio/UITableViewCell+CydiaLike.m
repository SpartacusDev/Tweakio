#import "UITableViewCell+CydiaLike.h"
#import <objc/runtime.h>


@implementation UITableViewCell (CydiaLike)

- (void)setIcon:(UIImageView *)myIcon {
    if (self.icon != nil) [self.icon removeFromSuperview];
    [myIcon setFrame:CGRectMake(
                              self.frame.origin.x + 10,
                              self.frame.size.height / 4,
                              20,
                              20
                              )];
    objc_setAssociatedObject(self, @selector(icon), myIcon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:self.icon];
}

- (void)setTitle:(UILabel *)myTitle {
    if (self.title != nil) [self.title removeFromSuperview];
    [myTitle setFrame:CGRectMake(
                               self.icon.frame.origin.x + self.icon.frame.size.width * 1.5,
                               0,
                               self.frame.size.width - self.frame.origin.x + self.frame.size.width,
                               self.frame.size.height
                               )];
    objc_setAssociatedObject(self, @selector(title), myTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:self.title];
}

- (UIImageView *)icon {
    return objc_getAssociatedObject(self, @selector(icon));
}

- (UILabel *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

@end

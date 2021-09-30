#import "TWMoreViewController.h"
#define bundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle"


@interface TWMoreViewController ()

@end

@implementation TWMoreViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.viewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"More";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.row) {
        case 0: {
            // UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            // [icon setImage:];
            // [cell setAccessoryView:icon];
            [cell.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWSearch.png", bundlePath]]]];
            [cell.textLabel setText:@"Search"];
            [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
            cell.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            break;
        }
        case 1: {
            // UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            // [icon setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWIcon.png", bundlePath]]]];
            [cell.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWIcon.png", bundlePath]]]];
            [cell.textLabel setText:@"Tweakio"];
            [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
            cell.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            break;
        }
        default:
            NSLog(@"Achievement unlocked: How did we get here?");
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.viewControllers.count) return;  // Seriously though, how?
    [self.navigationController pushViewController:self.viewControllers[indexPath.row] animated:YES];
}

@end

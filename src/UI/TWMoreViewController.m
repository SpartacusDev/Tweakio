#import "TWMoreViewController.h"
#import "src/common.h"


@interface TWMoreViewController ()

@end

@implementation TWMoreViewController

- (instancetype)init {
    if (@available(iOS 13, *))
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    else 
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
            if (@available(iOS 13, *)) {
                [cell.imageView setImage:[UIImage systemImageNamed:@"magnifyingglass"]];
            } else {
                [cell.imageView setImage:[
                    [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWSearch.png", BUNDLE_PATH]]]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate
                    ]
                ];
            }
            [cell.textLabel setText:@"Search"];
            [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
            cell.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            break;
        }
        case 1: {
            [cell.imageView setImage:[
                    [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/TWIcon.png", BUNDLE_PATH]]]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate
                ]
            ];
            [cell.imageView setTintColor:self.view.tintColor];
            [cell.textLabel setText:@"Tweakio"];
            [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
            cell.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
            break;
        }
        default:
            LOG(@"TWEAKIO: Achievement unlocked: How did we get here?");
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.viewControllers.count) return;  // Seriously though, how?
    [self.navigationController pushViewController:self.viewControllers[indexPath.row] animated:YES];
}

@end

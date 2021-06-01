#import "CydiaSettings.h"
#import "Settings.h"


@interface CydiaSettings ()

@property (nonatomic, strong) HomeController *parent;
@property (nonatomic, strong) NSArray *items;

@end

@implementation CydiaSettings

- (instancetype)initWithParent:(HomeController *)parent {
    self = [super init];
    if (self) self.parent = parent;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = @[
        @"About",
        @"Tweakio Settings"
    ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    [cell.textLabel setText:self.items[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.parent aboutButtonClicked];
            break;
        case 1:
            [self.navigationController pushViewController:[[Settings alloc] initWithPackageManager:@"Cydia" andBackgroundColor:UIColor.whiteColor] animated:YES];
            break;
        default:
            NSLog(@"Achievement unlocked! How did we get here?");
    }
}

@end
#import "TWReviewViewController.h"


@interface TWReviewViewController ()

@property (nonatomic, strong) NSArray<TWReview *> *reviews;

@end

@implementation TWReviewViewController

- (instancetype)initWithReviews:(NSArray<TWReview *> *)reviews {
    if (@available(iOS 13, *))
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    else 
        self = [super initWithStyle:UITableViewStyleGrouped];  
      
    if (self) {
        self.reviews = reviews;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    NSString *ratingString = @"";
    for (int i = 0; i < 5; i++) {
        ratingString = [ratingString stringByAppendingString:self.reviews[indexPath.row].rating >= i ? @"★" : @"☆" @"⯨"];
    }
    ratingString = [NSString stringWithFormat:@"%@ %i ", ratingString, self.reviews[indexPath.row].rating];

    if (self.reviews[indexPath.row].title) {
        if (self.reviews[indexPath.row].author) {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@ - %@\n%@", self.reviews[indexPath.row].title, self.reviews[indexPath.row].author, ratingString, self.reviews[indexPath.row].content]];
        } else {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@\n%@", self.reviews[indexPath.row].title, ratingString, self.reviews[indexPath.row].content]];
        }
    } else {
        if (self.reviews[indexPath.row].author) {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@\n%@", self.reviews[indexPath.row].author, ratingString, self.reviews[indexPath.row].content]];
        } else {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@\n%@", ratingString, self.reviews[indexPath.row].content]];
        }
    }

    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;

    UIFont *cellFont = cell.textLabel.font;
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize labelSize = [cell.textLabel.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont, NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;
    
    [cell.textLabel setFrame:CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, labelSize.width, labelSize.height)];

    return cell;
}

@end

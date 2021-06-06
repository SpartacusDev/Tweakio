#import "Settings.h"
#define preferencesPath @"/var/mobile/Library/Preferences/com.spartacus.tweakioprefs.plist"


@interface Settings ()

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableDictionary *prefs;
@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;

@end

@implementation Settings

- (instancetype)initWithPackageManager:(NSString *)packageManager andBackgroundColor:(UIColor *)backgroundColor{
	self = [super init];
	if (self) {
		self.backgroundColor = backgroundColor;
		self.packageManager = packageManager;
		self.prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesPath];
		if (![self.prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]]) self.prefs[[NSString stringWithFormat:@"%@ API", self.packageManager]] = 0;
		[self.prefs writeToURL:[NSURL fileURLWithPath:preferencesPath] error:nil];  // If it's somehow not in the plist
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:self.backgroundColor];

	self.pickerView = [[UIPickerView alloc] init];
	[self.pickerView setFrame:CGRectMake(
		(self.view.frame.size.width - self.pickerView.frame.size.width) / 2,
		(self.view.frame.size.height - self.pickerView.frame.size.height) / 2,
		self.pickerView.frame.size.width,
		self.pickerView.frame.size.height
	)];

	[self.pickerView setDataSource:self];
	[self.pickerView setDelegate:self];
	[self.pickerView selectRow:((NSNumber *)self.prefs[[NSString stringWithFormat:@"%@ API", self.packageManager]]).intValue inComponent:0 animated:YES];
	[self.view addSubview:self.pickerView];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.prefs writeToURL:[NSURL fileURLWithPath:preferencesPath] error:nil];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.prefs[[NSString stringWithFormat:@"%@ API", self.packageManager]] = [[NSNumber alloc] initWithInteger:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { 
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
		case 0:
			return @"Tweakio API";
		case 1:
			return @"Parcility API";
		case 2:
			return @"Canister API";
		default:
			return @"Achievement unlocked: How did we get here?";  // I mean, I do want to return something
	}
}

@end

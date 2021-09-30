#import "Settings.h"
#import <Cephei/HBPreferences.h>
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"


@interface Settings ()

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) HBPreferences *prefs;
@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UISegmentedControl *tweakioAPISearchingMethod;

@end

@implementation Settings

- (instancetype)initWithPackageManager:(NSString *)packageManager andBackgroundColor:(UIColor *)backgroundColor{
	self = [super init];
	if (self) {
		self.backgroundColor = backgroundColor;
		self.packageManager = packageManager;
		self.prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];
		if (![self.prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]])
			[self.prefs setObject:@0 forKey:[NSString stringWithFormat:@"%@ API", self.packageManager]];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:self.backgroundColor];

	self.pickerView = [[UIPickerView alloc] init];
	[self.pickerView setCenter:self.view.center];

	self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;

	[self.pickerView setDataSource:self];
	[self.pickerView setDelegate:self];
	[self.pickerView selectRow:((NSNumber *)[self.prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]]).intValue inComponent:0 animated:YES];
	[self.view addSubview:self.pickerView];
	
	[self.pickerView.widthAnchor constraintEqualToConstant:self.pickerView.frame.size.width].active = YES;
	[self.pickerView.heightAnchor constraintEqualToConstant:self.pickerView.frame.size.height].active = YES;
	[self.pickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.pickerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

	if ([self.pickerView selectedRowInComponent:0] == 0) [self presentSegmentedControl];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[self.prefs setObject:[NSNumber numberWithInteger:row] forKey:[NSString stringWithFormat:@"%@ API", self.packageManager]];
	switch (row) {
		case 0: {
			UIAlertController *deprecationNotice = [UIAlertController alertControllerWithTitle:@"Attention all passengers!" message:@"The Tweakio API is no longer maintained. You can still use it, but note that it is very outdated." preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Got it!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
			[deprecationNotice addAction:ok];
			[self presentViewController:deprecationNotice animated:YES completion:NULL];
			if (self.tweakioAPISearchingMethod && self.tweakioAPISearchingMethod.superview) return;
			[self presentSegmentedControl];
			break;
		}
		default:
			[self.tweakioAPISearchingMethod removeFromSuperview];
	}
}

- (void)presentSegmentedControl {
	if (!self.tweakioAPISearchingMethod) {
		self.tweakioAPISearchingMethod = [[UISegmentedControl alloc] initWithItems:@[
			@"Faster",
			@"More results"
		]];
		
		self.tweakioAPISearchingMethod.translatesAutoresizingMaskIntoConstraints = NO;

		[self.tweakioAPISearchingMethod addTarget:self action:@selector(selectSearchingMethod:) forControlEvents:UIControlEventValueChanged];

		[self.tweakioAPISearchingMethod setCenter:self.view.center];

		NSString *key = [NSString stringWithFormat:@"%@ Tweakio", self.packageManager];
		if (![self.prefs objectForKey:key])
			[self.prefs setObject:@0 forKey:key];
		[self.tweakioAPISearchingMethod setSelectedSegmentIndex:((NSNumber *)[self.prefs objectForKey:key]).intValue];
	}
	[self.view addSubview:self.tweakioAPISearchingMethod];
	[self.tweakioAPISearchingMethod.widthAnchor constraintEqualToConstant:self.tweakioAPISearchingMethod.frame.size.width].active = YES;
	[self.tweakioAPISearchingMethod.heightAnchor constraintEqualToConstant:self.tweakioAPISearchingMethod.frame.size.height].active = YES;
	[self.tweakioAPISearchingMethod.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.tweakioAPISearchingMethod.topAnchor constraintEqualToAnchor:self.pickerView.bottomAnchor constant:25].active = YES;
}

- (void)selectSearchingMethod:(UISegmentedControl *)sender {
	[self.prefs setObject:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:[NSString stringWithFormat:@"%@ Tweakio", self.packageManager]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { 
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
		case 0:
			return @"Tweakio API";
		case 1:
			return @"Parcility API";
		case 2:
			return @"Canister API";
		case 3:
			return @"iOS Repo Updates API";
		default:
			return @"Achievement unlocked: How did we get here?";  // I mean, I do want to return something
	}
}

@end

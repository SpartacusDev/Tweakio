#import "Settings.h"
#import <Cephei/HBPreferences.h>
#import "src/common.h"
#import "src/APIManagement/TWApiManager.h"
#import "src/APIManagement/TWBaseApi.h"


@interface Settings ()

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIPickerView *ratingsPickerView;
@property (nonatomic, strong) HBPreferences *prefs;
@property (nonatomic, strong) NSString *packageManager;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UISegmentedControl *apiSearchingOption;
@property (nonatomic, strong) TWApiManager *apiManager;

@end

@implementation Settings

- (instancetype)initWithPackageManager:(NSString *)packageManager andBackgroundColor:(UIColor *)backgroundColor{
	self = [super init];
	if (self) {
		self.backgroundColor = backgroundColor;
		self.packageManager = packageManager;
		self.prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
		self.apiManager = [TWApiManager sharedInstance];
	}
	return self;
}

- (int)indexOfRow {
	NSString *key = [self.prefs objectForKey:[NSString stringWithFormat:@"%@ API", self.packageManager]];
	for (int i = 0; i < [self.apiManager options].count; i++) {
		if ([[self.apiManager options][i].prefsValue isEqualToString:key]) {
			return i;
		}
	}
	return -1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView valueFromIndex:(int)index {
	if (pickerView == self.pickerView) {
		return [self.apiManager options][index].prefsValue;
	} else {
		return [self.apiManager ratingsOptions][index].prefsValue;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:self.backgroundColor];

	self.pickerView = [[UIPickerView alloc] init];
	[self.pickerView setCenter:self.view.center];

	self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;

	[self.pickerView setDataSource:self];
	[self.pickerView setDelegate:self];

	int index = [self indexOfRow];
	[self.pickerView selectRow:index == -1 ? 0 : index inComponent:0 animated:YES];
	[self.view addSubview:self.pickerView];
	
	[self.pickerView.widthAnchor constraintEqualToConstant:self.pickerView.frame.size.width].active = YES;
	[self.pickerView.heightAnchor constraintEqualToConstant:self.pickerView.frame.size.height].active = YES;
	[self.pickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.pickerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

	self.ratingsPickerView = [[UIPickerView alloc] init];
	[self.ratingsPickerView setCenter:self.view.center];

	self.ratingsPickerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.ratingsPickerView setDataSource:self];
	[self.ratingsPickerView setDelegate:self];
	[self.view addSubview:self.ratingsPickerView];

	[self.ratingsPickerView.widthAnchor constraintEqualToConstant:self.ratingsPickerView.frame.size.width].active = YES;
	[self.ratingsPickerView.heightAnchor constraintEqualToConstant:self.ratingsPickerView.frame.size.height].active = YES;
	[self.ratingsPickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.ratingsPickerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.pickerView.frame.size.height].active = YES;

	UILabel *apiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pickerView.frame.size.width, 20)], 
		*ratingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.ratingsPickerView.frame.size.width, 20)];
	[apiLabel setText:@"Searching API"];
	[apiLabel setTextAlignment:NSTextAlignmentCenter];
	[ratingsLabel setText:@"Ratings API"];
	[ratingsLabel setTextAlignment:NSTextAlignmentCenter];

	[self.pickerView addSubview:apiLabel];
	[self.ratingsPickerView addSubview:ratingsLabel];

	if ([self.apiManager options].count == 0) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No APIs found" message:@"Make sure to have a Tweakio API plugin installed" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:NULL];
		[alert addAction:ok];
		[self presentViewController:alert animated:YES completion:NULL];
		return;
	}

	if ([self.apiManager options][[self.pickerView selectedRowInComponent:0]].options) {
		[self presentSegmentedControl];
	}

	NSString *key = [NSString stringWithFormat:@"%@ API", self.packageManager];
	if ([self.prefs objectForKey:key] == nil) {
		[self.prefs setObject:[self.apiManager options][0].prefsValue forKey:key];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if ([self pickerView:pickerView numberOfRowsInComponent:0] == 0) {
		return;
	}

	if (pickerView == self.pickerView) {
		[self.prefs setObject:[self pickerView:pickerView valueFromIndex:row] forKey:[NSString stringWithFormat:@"%@ API", self.packageManager]];
		
		if ([self.apiManager options][row].options) {
			[self presentSegmentedControl];
		} else {
			[self removeSegmentedControl];
		}
	} else {
		[self.prefs setObject:[self pickerView:pickerView valueFromIndex:row] forKey:[NSString stringWithFormat:@"%@ ratings API", self.packageManager]];
	}
}

- (void)removeSegmentedControl {
	[self.apiSearchingOption removeFromSuperview];
	self.apiSearchingOption = nil;
}

- (void)presentSegmentedControl {
	if (!self.apiSearchingOption) {
		self.apiSearchingOption = [[UISegmentedControl alloc] initWithItems:
			[self.apiManager options][[self.pickerView selectedRowInComponent:0]].options
		];
		
		self.apiSearchingOption.translatesAutoresizingMaskIntoConstraints = NO;

		[self.apiSearchingOption addTarget:self action:@selector(selectSearchingMethod:) forControlEvents:UIControlEventValueChanged];

		[self.apiSearchingOption setCenter:self.view.center];

		NSString *key = [NSString stringWithFormat:@"%@ %@", self.packageManager, [self pickerView:self.pickerView valueFromIndex:[self.pickerView selectedRowInComponent:0]]];
		if (![self.prefs objectForKey:key])
			[self.prefs setObject:@0 forKey:key];
		[self.apiSearchingOption setSelectedSegmentIndex:((NSNumber *)[self.prefs objectForKey:key]).intValue];
	}
	[self.view addSubview:self.apiSearchingOption];
	[self.apiSearchingOption.widthAnchor constraintEqualToConstant:self.apiSearchingOption.frame.size.width].active = YES;
	[self.apiSearchingOption.heightAnchor constraintEqualToConstant:self.apiSearchingOption.frame.size.height].active = YES;
	[self.apiSearchingOption.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[self.apiSearchingOption.topAnchor constraintEqualToAnchor:self.pickerView.bottomAnchor constant:25].active = YES;
}

- (void)selectSearchingMethod:(UISegmentedControl *)sender {
	[self.prefs 
		setObject:[self.apiManager options][[self.pickerView selectedRowInComponent:0]].options[sender.selectedSegmentIndex]
		forKey:[NSString stringWithFormat:@"%@ %@", self.packageManager, [self pickerView:self.pickerView valueFromIndex:[self.pickerView selectedRowInComponent:0]]]
	];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { 
	if (pickerView == self.pickerView) {
    	return [self.apiManager options].count;
	} else {
		return [self.apiManager ratingsOptions].count;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (pickerView == self.pickerView) {
		return [self.apiManager options][row].name;
	} else {
		return [self.apiManager ratingsOptions][row].name;
	}
}

@end

#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#define preferencesFileName @"com.spartacus.tweakioprefs.plist"


%hook TWAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig(application);
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Tweakio"]]];
    [self.window makeKeyAndVisible];
}

%end

%ctor {
    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:preferencesFileName];

	if (![prefs objectForKey:@"Cydia API"]) [prefs setObject:@0 forKey:@"Cydia API"];
	if (![prefs objectForKey:@"Zebra API"]) [prefs setObject:@0 forKey:@"Zebra API"];
	if (![prefs objectForKey:@"Installer API"]) [prefs setObject:@0 forKey:@"Installer API"];
	if (![prefs objectForKey:@"Sileo API"]) [prefs setObject:@0 forKey:@"Sileo API"];
    if (![prefs objectForKey:@"Tweakio API"]) [prefs setObject:@0 forKey:@"Tweakio API"];
	
	if (![prefs objectForKey:@"cydia hooking method"]) [prefs setObject:@0 forKey:@"cydia hooking method"];
	if (![prefs objectForKey:@"zebra hooking method"]) [prefs setObject:@0 forKey:@"zebra hooking method"];
	if (![prefs objectForKey:@"installer hooking method"]) [prefs setObject:@0 forKey:@"installer hooking method"];
	if (![prefs objectForKey:@"sileo hooking method"]) [prefs setObject:@0 forKey:@"sileo hooking method"];
	
	if (![prefs objectForKey:@"cydia animation"]) [prefs setObject:@YES forKey:@"cydia animation"];
	if (![prefs objectForKey:@"zebra animation"]) [prefs setObject:@YES forKey:@"zebra animation"];
	if (![prefs objectForKey:@"installer animation"]) [prefs setObject:@YES forKey:@"installer animation"];
	if (![prefs objectForKey:@"sileo animation"]) [prefs setObject:@YES forKey:@"sileo animation"];

	if (![prefs objectForKey:@"cydia legacy"]) [prefs setObject:@NO forKey:@"cydia legacy"];
	if (![prefs objectForKey:@"zebra legacy"]) [prefs setObject:@NO forKey:@"zebra legacy"];
	if (![prefs objectForKey:@"installer legacy"]) [prefs setObject:@NO forKey:@"installer legacy"];
	if (![prefs objectForKey:@"sileo legacy"]) [prefs setObject:@NO forKey:@"sileo legacy"];
	if (![prefs objectForKey:@"tweakio legacy"]) [prefs setObject:@NO forKey:@"tweakio legacy"];    
}
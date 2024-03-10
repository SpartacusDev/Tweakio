#import <Cephei/HBPreferences.h>
#import "HookHeaders.h"
#import "src/common.h"


%hook TWAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig(application);

    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
	NSNumber *enabled = (NSNumber *)[prefs objectForKey:@"tweakio"];
	if (enabled && !enabled.boolValue) {
        return;
    }

    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[TweakioViewController alloc] initWithPackageManager:@"Tweakio"]]];
    [self.window makeKeyAndVisible];
}

%end

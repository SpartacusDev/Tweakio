#import "src/common.h"
#import <Cephei/HBPreferences.h>
#import <dlfcn.h>


NSString *getPackageManager() {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([bundleId isEqualToString:@"com.saurik.Cydia"]) {
        return @"Cydia";
    } else if ([bundleId isEqualToString:@"xyz.willy.Zebra"] || [bundleId isEqualToString:@"xyz.willy.Zebralpha"]) {
        return @"Zebra";
    } else if ([bundleId isEqualToString:@"me.apptapp.installer"]) {
        return @"Installer";
    } else if ([bundleId isEqualToString:@"org.coolstar.SileoStore"] || [bundleId isEqualToString:@"org.coolstar.SileoBeta"] || 
            [bundleId isEqualToString:@"org.coolstar.SileoNightly"]) {
        return @"Sileo";
    } else {
        return @"Tweakio";
    }
}

static __attribute__((constructor)) void main_initializer(void) {
    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:PREFERENCES_FILE_NAME];
    NSArray<NSString *> *pms = @[@"Cydia", @"Zebra", @"Installer", @"Sileo", @"Tweakio"];

    for (NSString *pm in pms) {
        if (![prefs objectForKey:[pm lowercaseString]]) {
            [prefs setObject:@YES forKey:[pm lowercaseString]];
        }
        if ([[prefs objectForKey:[NSString stringWithFormat:@"%@ API", pm]] class] == NSClassFromString(@"__NSCFNumber")) {
            [prefs removeObjectForKey:[NSString stringWithFormat:@"%@ API", pm]];
        }
        if (![prefs objectForKey:[NSString stringWithFormat:@"%@ hooking method", [pm lowercaseString]]]) {
            [prefs setObject:@0 forKey:[NSString stringWithFormat:@"%@ hooking method", [pm lowercaseString]]];
        }
        if (![prefs objectForKey:[NSString stringWithFormat:@"%@ animation", [pm lowercaseString]]]) {
            [prefs setObject:@YES forKey:[NSString stringWithFormat:@"%@ animation", [pm lowercaseString]]];
        }
        if (![prefs objectForKey:[NSString stringWithFormat:@"%@ legacy", [pm lowercaseString]]]) {
            [prefs setObject:@NO forKey:[NSString stringWithFormat:@"%@ legacy", [pm lowercaseString]]];
        }
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:PLUGINS_PATH error:nil];
    NSArray<NSString *> *tweakioPlugins = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.dylib'"]];
    for (NSString *filePath in tweakioPlugins) {
        dlopen([[PLUGINS_PATH stringByAppendingString:filePath] UTF8String], RTLD_LAZY);
    }
}
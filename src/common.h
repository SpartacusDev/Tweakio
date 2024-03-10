#ifndef COMMON_H
#define COMMON_H

#import <Foundation/Foundation.h>
#import <rootless.h>

#define PREFERENCES_FILE_NAME ROOT_PATH_NS(@"com.spartacus.tweakioprefs.plist")
#define BUNDLE_PATH ROOT_PATH_NS(@"/Library/MobileSubstrate/DynamicLibraries/com.spartacus.tweakio.bundle")
#define PLUGINS_PATH ROOT_PATH_NS(@"/Library/TweakioPlugins/")
#define DOWNLOADS_PATH @"/var/mobile/Downloads"

NSString *getPackageManager();

#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#else
#define LOG(...) 
#endif

#endif
#ifndef COMMON_H
#define COMMON_H

#import <rootless.h>

#define PREFERENCES_NAME @"com.spartacus.tweakioprefs"
#define APPLICATION_PATH ROOT_PATH_NS(@"/Applications/")
#define PLUGINS_PATH ROOT_PATH_NS(@"/Library/TweakioPlugins/")
#define CAPITALIZED_STRING(string) [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]]
#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#else
#define LOG(...) 
#endif

#endif
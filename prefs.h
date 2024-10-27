#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import "rootless.h"

/* {{{ Constants */
#define PLBundleKey @"pl_bundle"
extern NSString *const PLFilterKey;
#define PLAlternatePlistNameKey @"pl_alt_plist_name"
/* }}} */

@interface PSListController (libprefs)
- (NSArray *)specifiersFromEntry:(NSDictionary *)entry sourcePreferenceLoaderBundlePath:(NSString *)sourceBundlePath title:(NSString *)title;
@end

@interface PSSpecifier (libprefs)
+ (BOOL)environmentPassesPreferenceLoaderFilter:(NSDictionary *)filter;
@property (nonatomic, retain, readonly) NSBundle *preferenceLoaderBundle;
@end

@interface PLCustomListController: PSListController { }
@end

@interface PLLocalizedListController: PLCustomListController { }
@end

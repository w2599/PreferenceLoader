#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <substrate.h>

#import "prefs.h"

#define DEBUG_TAG "PreferenceLoader"
#import "debug.h"

%hook PrefsListController
static NSMutableArray *_loadedSpecifiers = nil;
static NSInteger _extraPrefsGroupSectionID = 0;

/* {{{ iPad Hooks */
%group iPad
- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	if([_loadedSpecifiers count] == 0) return %orig;
	if(section == _extraPrefsGroupSectionID) return NULL;
	return %orig;
}

- (CGFloat)tableView:(UITableView *)view heightForHeaderInSection:(NSInteger)section {
	if([_loadedSpecifiers count] == 0) return %orig;
	if(section == _extraPrefsGroupSectionID) return 10.f;
	return %orig;
}
%end
/* }}} */

static NSInteger PSSpecifierSort(PSSpecifier *a1, PSSpecifier *a2, void *context) {
	NSString *string1 = [a1 name];
	NSString *string2 = [a2 name];
	return [string1 localizedCaseInsensitiveCompare:string2];
}

- (id)specifiers {
	bool first = (MSHookIvar<id>(self, "_specifiers") == nil);
	if(first) {
		PLLog(@"initial invocation for -specifiers");
		%orig;
		[_loadedSpecifiers release];
		_loadedSpecifiers = [[NSMutableArray alloc] init];
		NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:@"/var/jb/Library/PreferenceLoader/Preferences" error:NULL];
		for(NSString *item in subpaths) {
			if(![[item pathExtension] isEqualToString:@"plist"]) continue;
			PLLog(@"processing %@", item);
			NSString *fullPath = [NSString stringWithFormat:@"/var/jb/Library/PreferenceLoader/Preferences/%@", item];
			NSDictionary *plPlist = [NSDictionary dictionaryWithContentsOfFile:fullPath];
			if(![PSSpecifier environmentPassesPreferenceLoaderFilter:[plPlist objectForKey:@"filter"] ?: [plPlist objectForKey:PLFilterKey]]) continue;

			NSDictionary *entry = [plPlist objectForKey:@"entry"];
			if(!entry) continue;
			PLLog(@"found an entry key for %@!", item);

			if(![PSSpecifier environmentPassesPreferenceLoaderFilter:[entry objectForKey:PLFilterKey]]) continue;

			NSArray *specs = [self specifiersFromEntry:entry sourcePreferenceLoaderBundlePath:[fullPath stringByDeletingLastPathComponent] title:[[item lastPathComponent] stringByDeletingPathExtension]];
			if(!specs) continue;

			PLLog(@"appending to the array!");
			[_loadedSpecifiers addObjectsFromArray:specs];
		}

		[_loadedSpecifiers sortUsingFunction:(NSInteger (*)(id, id, void *))&PSSpecifierSort context:NULL];

		if([_loadedSpecifiers count] > 0) {
			PLLog(@"so we gots us some specifiers! that's awesome! let's add them to the list...");
			PSSpecifier *groupSpecifier = [PSSpecifier groupSpecifierWithName:nil];
			[_loadedSpecifiers insertObject:groupSpecifier atIndex:0];
			NSMutableArray *_specifiers = MSHookIvar<NSMutableArray *>(self, "_specifiers");
			NSInteger firstindex = 2;
				
			PLLog(@"Adding to the end of entire list");

			NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstindex, [_loadedSpecifiers count])];
			[_specifiers insertObjects:_loadedSpecifiers atIndexes:indices];
			PLLog(@"getting group index");
			NSUInteger groupIndex = 0;
			for(PSSpecifier *spec in _specifiers) {
				if(MSHookIvar<NSInteger>(spec, "cellType") != PSGroupCell) continue;
				if(spec == groupSpecifier) break;
				++groupIndex;
			}
			_extraPrefsGroupSectionID = groupIndex;
			PLLog(@"group index is %d", _extraPrefsGroupSectionID);
		}
	}
	return MSHookIvar<id>(self, "_specifiers");
}
%end

%ctor {
	Class targetRootClass = objc_getClass("PSUIPrefsListController");
	if (targetRootClass == Nil) {
		targetRootClass = objc_getClass("PrefsListController");
	}
	%init(PrefsListController = targetRootClass);

	if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		%init(iPad);
}

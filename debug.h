#ifndef __DEBUG_H
#define __DEBUG_H

#ifndef DEBUG_TAG
#define DEBUG_TAG "PreferenceLoader"
#endif

#if DEBUG
#	define PLLog(...)
#else
#	define PLLog(...)
#endif

#endif

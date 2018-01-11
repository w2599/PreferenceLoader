IPHONE_ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PreferenceLoader
PreferenceLoader_FILES = Tweak.xm prefs.xm
PreferenceLoader_FRAMEWORKS = UIKit
PreferenceLoader_PRIVATE_FRAMEWORKS = Preferences
PreferenceLoader_CFLAGS = -I.
PreferenceLoader_USE_SUBSTRATE=0

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;
	$(FAKEROOT) chown -R 0:80 $(THEOS_STAGING_DIR)
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceBundles $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences

after-install::
	install.exec "killall -9 Preferences"

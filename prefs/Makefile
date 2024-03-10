include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TweakioPrefs

$(BUNDLE_NAME)_FILES = $(wildcard *.m)
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = CepheiPrefs
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

ifeq ($(ENABLELOGGING), 1)
	$(BUNDLE_NAME)_CFLAGS += -DDEBUG
endif

include $(THEOS_MAKE_PATH)/bundle.mk

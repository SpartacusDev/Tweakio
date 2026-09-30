export TARGET := iphone:clang:latest:12.0
export ARCHS = arm64 arm64e

# Rootless (Dopamine, iOS 15/16, palera1n):
#   make package ROOTLESS=1 FINALPACKAGE=1
# Rootful (unc0ver/checkra1n/Taurine, iOS 12-14):
#   make package FINALPACKAGE=1
ifeq ($(ROOTLESS), 1)
	export THEOS_PACKAGE_SCHEME = rootless
endif

# Theos uses the newest SDK it can find (the Xcode SDK on macOS, or whatever is
# in $(THEOS)/sdks). Uncomment and adjust to pin a specific one.
# export SYSROOT = $(THEOS)/sdks/iPhoneOS16.5.sdk

INSTALL_TARGET_PROCESSES = Cydia Zebra Installer Sileo Tweakio Preferences Zebra-Alpha Sileo-Beta Sileo-Nightly

ifeq ($(RELEASE), 1)
	PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
endif

ifeq ($(ENABLELOGGING), 1)
	export GO_EASY_ON_ME = 1
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Tweakio

BUNDLE_NAME = com.spartacus.tweakio

$(BUNDLE_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
# `find -E` is a BSD find extension; -name/-o behaves the same on BSD and GNU find.
$(TWEAK_NAME)_FILES = $(shell find ./src -type f -name '*.m') $(shell find ./src -type f -name '*.x')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wformat-security
$(TWEAK_NAME)_FRAMEWORKS += UIKit WebKit QuartzCore
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
	$(TWEAK_NAME)_CFLAGS += -DROOTLESS
endif
ifeq ($(ENABLELOGGING), 1)
	$(TWEAK_NAME)_CFLAGS += -DDEBUG
endif

include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

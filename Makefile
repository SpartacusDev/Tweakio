export TARGET := iphone:clang:latest:12.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk
INSTALL_TARGET_PROCESSES = Cydia Zebra Installer Sileo Tweakio Preferences Zebra-Alpha Sileo-Beta Sileo-Nightly
THEOS_DEVICE_IP = Spartacus-iPhone-2.local

ifeq ($(RELEASE), 1)
	PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
endif

ifeq ($(ENABLELOGGING), 1)
	export GO_EASY_ON_ME = 1
endif

ifeq ($(ROOTLESS), 1)
	export THEOS_PACKAGE_SCHEME = rootless
endif

include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e

TWEAK_NAME = Tweakio

BUNDLE_NAME = com.spartacus.tweakio

$(BUNDLE_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
$(TWEAK_NAME)_FILES = $(shell find -E ./src -regex ".*\.(m|x)" -type f)
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

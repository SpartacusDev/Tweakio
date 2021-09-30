PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
export TARGET := iphone:clang:latest:12.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS12.1.2.sdk
INSTALL_TARGET_PROCESSES = Cydia Zebra Installer Sileo

include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e

TWEAK_NAME = Tweakio

BUNDLE_NAME = com.spartacus.tweakio

$(BUNDLE_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
$(TWEAK_NAME)_FILES = $(wildcard *.x) $(wildcard Tweakio/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS += UIKit WebKit QuartzCore
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += tweakioprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

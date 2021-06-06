PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
TARGET := iphone:clang:latest:12.0
INSTALL_TARGET_PROCESSES = Cydia Zebra Installer Sileo

include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

TWEAK_NAME = Tweakio

BUNDLE_NAME = com.spartacus.tweakio

$(BUNDLE_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
$(TWEAK_NAME)_FILES = $(wildcard *.x) $(wildcard Tweakio/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += tweakioprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

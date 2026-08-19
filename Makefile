TARGET := iphone:clang:latest:latest
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SatellaJailed

SatellaJailed_FILES = Tweak/Sources/SatellaJailed/Tweak.swift Tweak/Sources/load.s

SPM_MODULE_DIR = $(shell find .build -name "Jinx.swiftmodule" 2>/dev/null | head -n 1 | xargs dirname)

SDK_PATH = $(shell xcrun --sdk iphoneos --show-sdk-path)

SatellaJailed_SWIFTFLAGS = \
	-swift-version 5 \
	-I$(SPM_MODULE_DIR) \
	-sdk $(SDK_PATH) \
	-target arm64-apple-ios14.0

SatellaJailed_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

before-all::
	@echo "========================================"
	@echo "Swift / iOS SDK information"
	@echo "========================================"
	@echo "SDK_PATH=$(SDK_PATH)"
	@echo "SPM_MODULE_DIR=$(SPM_MODULE_DIR)"
	@echo ""

	@if [ -z "$(SDK_PATH)" ]; then \
		echo "ERROR: SDK_PATH is empty."; \
		exit 1; \
	fi

	@if [ ! -d "$(SDK_PATH)" ]; then \
		echo "ERROR: SDK does not exist:"; \
		echo "$(SDK_PATH)"; \
		exit 1; \
	fi

	@if [ ! -d "$(SDK_PATH)/System/Library/Frameworks/UIKit.framework" ]; then \
		echo "ERROR: UIKit.framework not found."; \
		exit 1; \
	fi

	@echo "UIKit.framework found."
	@echo ""

	swift package resolve

	@echo "========================================"
	@echo "Building Jinx for iOS"
	@echo "========================================"

	swift build \
		--sdk "$(SDK_PATH)" \
		--triple arm64-apple-ios14.0

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += prefs

include $(THEOS_MAKE_PATH)/aggregate.mk

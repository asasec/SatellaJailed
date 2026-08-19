TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SatellaJailed

# Sources/SatellaJailed altındaki tüm Swift dosyaları ve load.s derlemeye dahil edildi
SatellaJailed_FILES = $(wildcard Sources/SatellaJailed/*.swift) \
                      $(wildcard Sources/SatellaJailed/**/*.swift) \
                      Sources/load.s

SDK_PATH = $(shell xcrun --sdk iphoneos --show-sdk-path)
SPM_MODULE_DIR = $(shell find .build -name "Jinx.swiftmodule" 2>/dev/null | head -n 1 | xargs dirname)
JINX_LIB = $(shell find .build -name "libJinx.a" -o -name "Jinx.o" 2>/dev/null | head -n 1)

SatellaJailed_SWIFTFLAGS = \
	-swift-version 5 \
	-I$(SPM_MODULE_DIR) \
	-sdk $(SDK_PATH) \
	-target arm64-apple-ios14.0

SatellaJailed_CFLAGS = -fobjc-arc

# Jinx kütüphanesini bağlayıcıya (linker) bildiriyoruz
SatellaJailed_LDFLAGS = $(JINX_LIB)

include $(THEOS_MAKE_PATH)/tweak.mk

before-all::
	@echo "========================================"
	@echo "Swift / iOS SDK information"
	@echo "========================================"
	@echo "SDK_PATH=$(SDK_PATH)"
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
	@echo "Building Jinx dependency"
	@echo "========================================"

	swift build \
		--sdk "$(SDK_PATH)" \
		--triple arm64-apple-ios14.0

	@echo "========================================"
	@echo "Checking .build directory contents:"
	@echo "========================================"
	@ls -R .build || echo ".build directory not found or empty!"
	@echo "JINX_LIB found at: $(JINX_LIB)"
	@echo ""

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += prefs

include $(THEOS_MAKE_PATH)/aggregate.mk

PWD = $(shell pwd)
REPO_ROOT = $(abspath $(PWD))
PYTHON = python3
MARKETING_VERSION = $(shell sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' GStreamerBrilliant/GStreamerBrilliant.xcodeproj/project.pbxproj)
GSTREAMER_VERSION = $(shell readlink ~/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework/Versions/Current | sed -e 's/BRL//g')
LIBRARY_VERSION = $(shell echo "$(MARKETING_VERSION).$(GSTREAMER_VERSION)")
UNDERSCORE_VERSION = $(shell echo $(LIBRARY_VERSION) | sed -e 's/\./_/g')
OUTPUTNAME = $(shell echo "build/gstreamer-brilliant-ios-$(UNDERSCORE_VERSION).xcframework.tar.gz")

.DEFAULT_GOAL := tar
.PHONY = arm64 x86_64 xcframework tar clean set_version

set_version:
	cd GStreamerBrilliant && agvtool new-version -all "$(LIBRARY_VERSION)"

arm64:
	cd GStreamerBrilliant && xcodebuild archive \
		-scheme GStreamerBrilliant \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath '../build/GStreamerBrilliant.framework-iphoneos.xcarchive' \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

x86_64:
	cd GStreamerBrilliant && xcodebuild archive \
		-scheme GStreamerBrilliant \
		-configuration Release \
		-destination 'generic/platform=iOS Simulator' \
		-archivePath '../build/GStreamerBrilliant.framework-iphonesimulator.xcarchive' \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcframework: set_version arm64 x86_64
	xcodebuild -create-xcframework \
		-framework './build/GStreamerBrilliant.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/GStreamerBrilliant.framework' \
		-framework './build/GStreamerBrilliant.framework-iphoneos.xcarchive/Products/Library/Frameworks/GStreamerBrilliant.framework' \
		-output './build/GStreamerBrilliant.xcframework'

tar: xcframework
	tar -C build -zcvf $(OUTPUTNAME) GStreamerBrilliant.xcframework

clean:
	rm -rf build/*

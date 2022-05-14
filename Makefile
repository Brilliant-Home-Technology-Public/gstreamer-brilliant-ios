PWD = $(shell pwd)
REPO_ROOT = $(abspath $(PWD))
PYTHON = python3
GITSHA = $(shell git rev-parse --short HEAD)
OUTPUTNAME = $(shell echo "build/gstreamer-brilliant-ios-$(GITSHA).xcframework.tar.gz")

.DEFAULT_GOAL := tar
.PHONY = arm64 x86_64 xcframework tar clean

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

xcframework: arm64 x86_64
	xcodebuild -create-xcframework \
		-framework './build/GStreamerBrilliant.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/GStreamerBrilliant.framework' \
		-framework './build/GStreamerBrilliant.framework-iphoneos.xcarchive/Products/Library/Frameworks/GStreamerBrilliant.framework' \
		-output './build/GStreamerBrilliant.xcframework'

tar: xcframework
	tar -C build -zcvf $(OUTPUTNAME) GStreamerBrilliant.xcframework

clean:
	rm -rf build/*

PWD = $(shell pwd)
REPO_ROOT = $(abspath $(PWD))
PYTHON = python3
GITSHA = $(shell git rev-parse --short HEAD)
OUTPUTNAME = $(shell echo "build/gstreamer-brilliant-ios-$(GITSHA).xcframework.tar.gz")

.DEFAULT_GOAL := tar
.PHONY = arm64 x86_64 xcframework tar clean

arm64:
	cd GStreamer-Brilliant && xcodebuild archive \
		-scheme GStreamer-Brilliant \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath '../build/GStreamer_Brilliant.framework-iphoneos.xcarchive' \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

x86_64:
	cd GStreamer-Brilliant && xcodebuild archive \
		-scheme GStreamer-Brilliant \
		-configuration Release \
		-destination 'generic/platform=iOS Simulator' \
		-archivePath '../build/GStreamer_Brilliant.framework-iphonesimulator.xcarchive' \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcframework: arm64 x86_64
	xcodebuild -create-xcframework \
		-framework './build/GStreamer_Brilliant.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/GStreamer_Brilliant.framework' \
		-framework './build/GStreamer_Brilliant.framework-iphoneos.xcarchive/Products/Library/Frameworks/GStreamer_Brilliant.framework' \
		-output './build/GStreamer_Brilliant.xcframework'

tar: xcframework
	tar -C build -zcvf $(OUTPUTNAME) GStreamer_Brilliant.xcframework

clean:
	rm -rf build/*

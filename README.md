# gstreamer-brilliant-ios
This is the Brilliant iOS GStreamer Backend.

Based on the example code from the GStreamer Library, this repository can generate an xcframework that will allow a client to generate an RTSP GStreamer pipeline and run it.

## Requirements
A valid GStreamer installation located at `~/Library/Developer/GStreamer`

## Updating Version
1) Increment the `MARKETING_VERSION` in the project via XCode or text editor.
2) Run `make set-version` to update the bundle version to be a concatenation of the `MARKETING_VERSION` and the currently installed GStreamer version.

## Building
Each of the following commands builds will run all previous commands (e.g. `make tar` builds for both platforms AND puts them in an xcframework first).
All products will be located in `<repo root>/build`

### To build a framework for an individual platform, run one of:
* `make arm64`
* `make x86_64`

### To build an xcframework containing both, run:
* `make xcframework`

### To make a tar of the xcframework, run:
* `make tar`

## Cleaning
Run `make clean` to clean contents of build folder.

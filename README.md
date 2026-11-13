# Exif Transfer

Exif Transfer is a macOS app for copying metadata from one image to another with ExifTool.

## Features

- Drag a source image and a target image into the app.
- Copy metadata from the source image to the target.
- Write to the target or save a dated copy in Downloads.

## Requirements

- macOS 14 or later.
- ExifTool, installed with `brew install exiftool`.
- Xcode to build from source.

## Usage

Drop the image with the metadata into Source and the destination image into Target. Select Direct Overwrite to update the target file. Turn it off to save a dated copy in Downloads. Select Transfer Metadata to run the transfer.

## Design

The interface has separate Source and Target drop zones, transfer status, and one transfer action. `AppViewModel` manages image selection and transfer state. `ExifToolService` locates the installed ExifTool executable and runs the transfer. Sparkle handles app updates.

## Build

Open `exiftransfer.xcodeproj` in Xcode and build the `Exif Transfer` target.

## License

Exif Transfer is licensed under GPL-3.0. See [LICENSE](LICENSE). ExifTool's license is in [LICENSE-exiftool](LICENSE-exiftool). Sparkle's license is in [LICENSE-Sparkle](LICENSE-Sparkle).

## Issues

Report bugs and request features in the [GitHub issue tracker](https://github.com/mvllet/exiftransfer/issues).

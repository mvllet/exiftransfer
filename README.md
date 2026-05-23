# Exif Transfer

macOS utility that copies EXIF metadata from one image to another.

## Prerequisites

- [exiftool](https://exiftool.org) - install via Homebrew: `brew install exiftool`

## Usage

1. Drag a source image (with EXIF data) onto the left drop zone.
2. Drag a target image onto the right drop zone.
3. Click **Transfer Metadata**.

### Modes

- **Direct overwrite**: writes metadata directly to the target file.
- **Copy to Downloads**: creates a dated copy in `~/Downloads` before writing.

## Build

Open `exiftransfer.xcodeproj` in Xcode 26+ and run.

## License

#### Copyright (c) 2026 Mullet. All rights reserved.

This software is provided for personal or internal use.
- **Prohibited**: Commercial sale, redistribution, or integration into other commercial projects without express written permission from **Mullet**.
- See the `LICENSE` file for full details.

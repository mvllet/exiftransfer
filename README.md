# Exif Transfer

A native macOS app for copying EXIF metadata from one image to another. Built with SwiftUI.

## Prerequisites

**Dependencies**
- exiftool (https://exiftool.org)
- Homebrew installation via `brew install exiftool`

## Usage

**Workflow**
- Left drop zone for source images with EXIF data
- Right drop zone for target images
- One-click Transfer Metadata action

**Modes**
- Direct overwrite to write metadata directly to the target file
- Copy to Downloads to create a dated copy in `~/Downloads` before writing

## Technical Architecture

- Built with Swift 6 and modern concurrency
- Supports macOS 14 Sonoma through macOS 27 Golden Gate

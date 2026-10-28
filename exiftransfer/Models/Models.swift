import AppKit
import Foundation

enum DropRole {
    case source
    case target
}

struct ImageSlotState {
    var url: URL?
    var image: NSImage?
    var isTargeted: Bool = false
    var flash: Bool = false
}

enum TransferMode {
    case directOverwrite
    case copyToDownloads
}

struct ExifToolRunOutput {
    let destinationURL: URL
}

enum TransferError: LocalizedError, Equatable {
    case missingSource
    case missingTarget
    case sameFile
    case invalidDroppedItem
    case copyFailed(String)
    case exifToolNotFound
    case processFailed(status: Int32, message: String)

    var errorDescription: String? {
        switch self {
        case .missingSource:
            return "No source selected."
        case .missingTarget:
            return "No destination selected."
        case .sameFile:
            return "The source and destination must not be the same."
        case .invalidDroppedItem:
            return "The uploaded file could not be read."
        case .copyFailed(let message):
            return "Copy failed: \(message)"
        case .exifToolNotFound:
            return "exiftool was not found."
        case .processFailed(let status, let message):
            return "exiftool failed. Status \(status). \(message)"
        }
    }
}

enum AppStatus: Equatable {
    case idle
    case ready(String)
    case success(String)
    case failure(String)
}

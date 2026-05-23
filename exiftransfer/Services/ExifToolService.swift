// ExifToolService.swift

import Foundation

// Executes exiftool asynchronously and encapsulates process and file errors.
struct ExifToolService {
    func transferMetadata(
        from sourceURL: URL,
        to targetURL: URL,
        mode: TransferMode
    ) async -> Result<ExifToolRunOutput, TransferError> {
        do {
            let destinationURL = try resolvedDestinationURL(from: targetURL, mode: mode)
            return await runExifTool(sourceURL: sourceURL, destinationURL: destinationURL)
        } catch let error as TransferError {
            return .failure(error)
        } catch {
            return .failure(.copyFailed(error.localizedDescription))
        }
    }

    private func resolvedDestinationURL(from targetURL: URL, mode: TransferMode) throws -> URL {
        switch mode {
        case .directOverwrite:
            return targetURL
        case .copyToDownloads:
            return try copyTargetToDownloads(targetURL)
        }
    }

    private func copyTargetToDownloads(_ targetURL: URL) throws -> URL {
        let fileManager = FileManager.default

        guard let downloadsURL = fileManager.urls(
            for: .downloadsDirectory,
            in: .userDomainMask
        ).first else {
            throw TransferError.copyFailed("Downloads folder not found.")
        }

        let destinationURL = uniqueDownloadURL(
            baseName: targetURL.deletingPathExtension().lastPathComponent,
            fileExtension: targetURL.pathExtension,
            folderURL: downloadsURL
        )

        do {
            try fileManager.copyItem(at: targetURL, to: destinationURL)
            return destinationURL
        } catch {
            throw TransferError.copyFailed(error.localizedDescription)
        }
    }

    private func uniqueDownloadURL(
        baseName: String,
        fileExtension: String,
        folderURL: URL
    ) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HHmmss"

        let stamp = formatter.string(from: Date())
        let stem = [baseName, stamp]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        let fileName = fileExtension.isEmpty
            ? stem
            : "\(stem).\(fileExtension)"

        return folderURL.appendingPathComponent(fileName)
    }

    private func runExifTool(
        sourceURL: URL,
        destinationURL: URL
    ) async -> Result<ExifToolRunOutput, TransferError> {
        guard let exifToolURL = resolvedExifToolURL() else {
            return .failure(.exifToolNotFound)
        }

        return await withCheckedContinuation { continuation in
            let process = Process()
            let standardOutputPipe = Pipe()
            let standardErrorPipe = Pipe()

            process.executableURL = exifToolURL
            process.arguments = [
                "-tagsFromFile",
                sourceURL.path,
                "-overwrite_original",
                "-P",
                destinationURL.path
            ]

            process.standardOutput = standardOutputPipe
            process.standardError = standardErrorPipe

            process.terminationHandler = { terminatedProcess in
                let standardOutput = Self.readPipeText(standardOutputPipe)
                let standardError = Self.readPipeText(standardErrorPipe)

                if terminatedProcess.terminationStatus == 0 {
                    continuation.resume(
                        returning: .success(
                            ExifToolRunOutput(
                                destinationURL: destinationURL,
                                standardOutput: standardOutput,
                                standardError: standardError
                            )
                        )
                    )
                } else {
                    let message = standardError.isEmpty
                        ? standardOutput
                        : standardError

                    continuation.resume(
                        returning: .failure(
                            .processFailed(
                                status: terminatedProcess.terminationStatus,
                                message: message
                            )
                        )
                    )
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(
                    returning: .failure(.exifToolNotFound)
                )
            }
        }
    }

    private func resolvedExifToolURL() -> URL? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["which", "exiftool"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let path = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return path.isEmpty ? nil : URL(fileURLWithPath: path)
        } catch {
            return nil
        }
    }

    nonisolated private static func readPipeText(_ pipe: Pipe) -> String {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

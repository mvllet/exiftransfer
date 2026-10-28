import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class AppViewModel: ObservableObject {
    @Published var sourceSlot = ImageSlotState()
    @Published var targetSlot = ImageSlotState()
    @Published var directOverwrite = true
    @Published var isTransferring = false
    @Published var status: AppStatus = .idle

    private let service = ExifToolService()

    var canTransfer: Bool {
        sourceSlot.url != nil && targetSlot.url != nil && !isTransferring
    }

    func handleDrop(providers: [NSItemProvider], role: DropRole) -> Bool {
        guard let provider = providers.first else {
            return false
        }

        Task { [weak self] in
            guard let self else {
                return
            }

            let url = await self.loadFileURL(from: provider)
            self.handleLoadedURL(url, role: role)
        }

        return true
    }

    func transferMetadata() async {
        guard let sourceURL = sourceSlot.url else {
            status = .failure(TransferError.missingSource.localizedDescription)
            return
        }

        guard let targetURL = targetSlot.url else {
            status = .failure(TransferError.missingTarget.localizedDescription)
            return
        }

        guard sourceURL != targetURL else {
            status = .failure(TransferError.sameFile.localizedDescription)
            return
        }

        isTransferring = true
        status = .ready("Metadata has been transferred …")

        let mode: TransferMode = directOverwrite ? .directOverwrite : .copyToDownloads
        let result = await service.transferMetadata(from: sourceURL, to: targetURL, mode: mode)

        isTransferring = false

        switch result {
        case .success(let output):
            status = .success("Finished: \(output.destinationURL.lastPathComponent)")
            triggerFlash()
        case .failure(let error):
            status = .failure(error.localizedDescription)
        }
    }

    private func handleLoadedURL(_ url: URL?, role: DropRole) {
        guard let url else {
            status = .failure(TransferError.invalidDroppedItem.localizedDescription)
            return
        }

        assign(url: url, to: role)
    }

    private func assign(url: URL, to role: DropRole) {
        let image = NSImage(contentsOf: url)

        switch role {
        case .source:
            sourceSlot.url = url
            sourceSlot.image = image
            sourceSlot.flash = false
        case .target:
            targetSlot.url = url
            targetSlot.image = image
            targetSlot.flash = false
        }

        status = .idle
    }

    private func triggerFlash() {
        targetSlot.flash = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(450))
            targetSlot.flash = false
        }
    }

    private nonisolated func loadFileURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                    return
                }

                if let nsurl = item as? NSURL {
                    continuation.resume(returning: nsurl as URL)
                    return
                }

                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    continuation.resume(returning: url)
                    return
                }

                continuation.resume(returning: nil)
            }
        }
    }
}

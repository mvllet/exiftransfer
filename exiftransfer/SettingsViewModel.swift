// SettingsViewModel.swift

import Combine
import Sparkle
import SwiftUI

// MainActor-backed Sparkle state bridge for SwiftUI bindings.
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var automaticallyChecksForUpdates: Bool {
        didSet {
            guard automaticallyChecksForUpdates != updater.automaticallyChecksForUpdates else {
                return
            }

            updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }

    @Published var automaticallyDownloadsUpdates: Bool {
        didSet {
            guard automaticallyDownloadsUpdates != updater.automaticallyDownloadsUpdates else {
                return
            }

            updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates
        }
    }

    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }

    func refresh() {
        automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }
}

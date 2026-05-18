// exiftransferApp.swift

import SwiftUI
import Sparkle

@main
@MainActor
struct exiftransferApp: App {
    @StateObject private var viewModel = AppViewModel()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 400, minHeight: 300)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for updates …") {
                    updaterController.checkForUpdates(nil)
                }
            }
        }

        Settings {
            SettingsView(updater: updaterController.updater)
        }
    }
}

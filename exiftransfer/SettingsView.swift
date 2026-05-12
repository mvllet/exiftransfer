// SettingsView.swift

import Sparkle
import SwiftUI

// Settings window with Sparkle update controls and changelog sheet.
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showChangelog = false

    init(updater: SPUUpdater) {
        _viewModel = StateObject(
            wrappedValue: SettingsViewModel(updater: updater)
        )
    }

    var body: some View {
        Form {
            Section("Updates") {
                Button("Check for Updates") {
                    viewModel.checkForUpdates()
                }

                Button("What's New") {
                    showChangelog = true
                }

                Toggle(
                    "Automatically Check for Updates",
                    isOn: $viewModel.automaticallyChecksForUpdates
                )

                Toggle(
                    "Automatically Download and Install Updates",
                    isOn: $viewModel.automaticallyDownloadsUpdates
                )
                .disabled(!viewModel.automaticallyChecksForUpdates)
            }
        }
        .padding(20)
        .frame(width: 360)
        .sheet(isPresented: $showChangelog) {
            ChangelogView()
        }
    }
}

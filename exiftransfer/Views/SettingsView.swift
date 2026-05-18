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
                Toggle("Check for updates automatically", isOn: $viewModel.automaticallyChecksForUpdates)
                    .onChange(of: viewModel.automaticallyChecksForUpdates) { _, newValue in
                        viewModel.setAutomaticallyChecksForUpdates(newValue)
                    }

                Toggle("Automatically download and install updates", isOn: $viewModel.automaticallyDownloadsUpdates)
                    .disabled(!viewModel.automaticallyChecksForUpdates)
                    .onChange(of: viewModel.automaticallyDownloadsUpdates) { _, newValue in
                        viewModel.setAutomaticallyDownloadsUpdates(newValue)
                    }

                Button("Check Now") {
                    viewModel.checkForUpdates()
                }
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Button("What's New") {
                    showChangelog = true
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
        .sheet(isPresented: $showChangelog) {
            ChangelogView()
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

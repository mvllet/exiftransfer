import Sparkle
import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showChangelog = false

    init(updater: SPUUpdater) {
        _viewModel = State(
            initialValue: SettingsViewModel(updater: updater)
        )
    }

    var body: some View {
        Form {
            Section("Updates") {
                Toggle("Check for updates on launch", isOn: $viewModel.checksForUpdatesOnLaunch)
                    .onChange(of: viewModel.checksForUpdatesOnLaunch) { _, newValue in
                        viewModel.setChecksForUpdatesOnLaunch(newValue)
                    }

                Toggle("Automatically download & install updates", isOn: $viewModel.automaticallyDownloadsUpdates)
                    .onChange(of: viewModel.automaticallyDownloadsUpdates) { _, newValue in
                        viewModel.setAutomaticallyDownloadsUpdates(newValue)
                    }
                
                HStack {
                    Spacer()
                    Button("Check Now") {
                        viewModel.checkForUpdates()
                    }
                }
            }

            Section("About") {
                HStack {
                    Text("Version \(appVersion)")
                    Spacer()
                    Button("What's New") {
                        showChangelog = true
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .fixedSize(horizontal: false, vertical: true)
        .sheet(isPresented: $showChangelog) {
            ChangelogView()
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

}

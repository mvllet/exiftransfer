import Sparkle
import SwiftUI

private struct HiddenWindowToolbarBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 27, *) {
            content.toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        } else {
            content
        }
    }
}

extension View {
    fileprivate func hiddenWindowToolbarBackground() -> some View {
        modifier(HiddenWindowToolbarBackground())
    }
}

private struct DisallowWindowTabbing: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.tabbingMode = .disallowed
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        view.window?.tabbingMode = .disallowed
    }
}

extension View {
    fileprivate func disallowWindowTabbing() -> some View {
        background(DisallowWindowTabbing())
    }
}

@main
struct exiftransferApp: App {
    @StateObject private var viewModel = AppViewModel()
    private let updaterController: SPUStandardUpdaterController

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        updaterController.updater.automaticallyChecksForUpdates = false

        if SettingsViewModel.checksForUpdatesOnLaunch {
            updaterController.updater.checkForUpdatesInBackground()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .hiddenWindowToolbarBackground()
                .disallowWindowTabbing()
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") {
                    updaterController.checkForUpdates(nil)
                }
            }
        }

        Settings {
            SettingsView(updater: updaterController.updater)
                .hiddenWindowToolbarBackground()
                .disallowWindowTabbing()
        }
    }
}

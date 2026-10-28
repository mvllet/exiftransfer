import Observation
import Sparkle

@Observable
@MainActor
final class SettingsViewModel {
    private static let checkForUpdatesOnLaunchKey = "checkForUpdatesOnLaunch"

    static var checksForUpdatesOnLaunch: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: checkForUpdatesOnLaunchKey) != nil else {
            return true
        }
        return defaults.bool(forKey: checkForUpdatesOnLaunchKey)
    }

    var checksForUpdatesOnLaunch: Bool
    var automaticallyDownloadsUpdates: Bool

    private let updater: SPUUpdater
    private var observations: [NSKeyValueObservation] = []

    init(updater: SPUUpdater) {
        self.updater = updater
        self.checksForUpdatesOnLaunch = Self.checksForUpdatesOnLaunch
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates

        observeUpdater()
    }

    private func observeUpdater() {
        observations.append(
            updater.observe(\.automaticallyDownloadsUpdates, options: .new) { [weak self] _, change in
                guard let self, let newValue = change.newValue else { return }
                Task { @MainActor in
                    self.automaticallyDownloadsUpdates = newValue
                }
            }
        )

    }

    func setChecksForUpdatesOnLaunch(_ newValue: Bool) {
        checksForUpdatesOnLaunch = newValue
        UserDefaults.standard.set(newValue, forKey: Self.checkForUpdatesOnLaunchKey)
    }

    func setAutomaticallyDownloadsUpdates(_ newValue: Bool) {
        automaticallyDownloadsUpdates = newValue
        updater.automaticallyDownloadsUpdates = newValue
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}

import Foundation
import Observation
import ServiceManagement

@Observable
@MainActor
final class UsageViewModel {
    private(set) var usage: FetchUsageResponse?
    private(set) var errorMessage: String?
    private(set) var lastUpdated: Date?
    private(set) var isLoading: Bool = false
    var pollingInterval: PollingInterval = .fiveMinutes
    private(set) var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    var labelColor: MenuBarLabelColor {
        didSet {
            UserDefaults.standard.set(
                labelColor.rawValue,
                forKey: Self.labelColorDefaultsKey
            )
        }
    }

    private static let labelColorDefaultsKey = "menuBarLabelColor"

    private let fetchUsage: FetchUsageUseCaseProtocol

    init(fetchUsage: FetchUsageUseCaseProtocol) {
        self.fetchUsage = fetchUsage
        let stored = UserDefaults.standard.string(forKey: Self.labelColorDefaultsKey)
        labelColor = stored.flatMap(MenuBarLabelColor.init(rawValue:)) ?? .auto
    }

    func poll() async {
        await refresh()
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(pollingInterval.seconds))
            guard !Task.isCancelled else { break }
            await refresh()
        }
    }

    func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {}
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let request = FetchUsageRequest()
            usage = try await fetchUsage.execute(request)
            errorMessage = nil
            lastUpdated = .now
        } catch {
            usage = nil
            errorMessage = error.localizedDescription
        }
    }
}

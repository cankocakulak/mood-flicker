import Combine
import Foundation

@MainActor
final class HealthViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(HealthStatus)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let service: HealthAPI
    private let logger: AppLogger

    init(service: HealthAPI, logger: AppLogger) {
        self.service = service
        self.logger = logger
    }

    func load() async {
        state = .loading

        do {
            let status = try await service.fetchHealth()
            logger.debug("Health status loaded")
            state = .loaded(status)
        } catch {
            logger.error("Failed to load health status: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }
}

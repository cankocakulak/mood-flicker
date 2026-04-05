import Foundation
import OSLog

protocol AppLogger: Sendable {
    func debug(_ message: String)
    func error(_ message: String)
}

struct LiveAppLogger: AppLogger {
    private let logger: Logger

    init(subsystem: String, category: String = "app") {
        logger = Logger(subsystem: subsystem, category: category)
    }

    func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}

enum AppLoggerFactory {
    static func live(subsystem: String, category: String = "app") -> AppLogger {
        LiveAppLogger(subsystem: subsystem, category: category)
    }
}

extension AppLogger {
    static func live(subsystem: String, category: String = "app") -> AppLogger {
        AppLoggerFactory.live(subsystem: subsystem, category: category)
    }
}

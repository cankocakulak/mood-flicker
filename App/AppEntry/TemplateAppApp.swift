import SwiftUI

@main
struct TemplateAppApp: App {
    private let container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: HealthViewModel(service: container.healthAPI, logger: container.logger))
        }
    }
}

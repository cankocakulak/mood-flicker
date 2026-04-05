import SwiftUI

struct HealthView: View {
    @ObservedObject var viewModel: HealthViewModel

    var body: some View {
        List {
            Section("Status") {
                switch viewModel.state {
                case .idle:
                    Text("Ready")
                        .accessibilityIdentifier("health-state-idle")
                case .loading:
                    ProgressView()
                        .accessibilityIdentifier("health-state-loading")
                case let .loaded(status):
                    Label(
                        status.ok ? "Backend reachable" : "Backend unhealthy",
                        systemImage: status.ok ? "checkmark.circle.fill" : "xmark.octagon.fill")
                        .foregroundStyle(status.ok ? .green : .red)
                        .accessibilityIdentifier("health-state-loaded")
                    if let services = status.services {
                        ForEach(services.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key.capitalized)
                                Spacer()
                                Text(services[key] ?? "unknown")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                case let .failed(message):
                    Text(message)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("health-state-failed")
                }
            }

            Section("Environment") {
                Text(Bundle.main.object(forInfoDictionaryKey: "AppEnvironmentName") as? String ?? "Unknown")
                Text(Bundle.main.object(forInfoDictionaryKey: "AppAPIBaseURL") as? String ?? "Missing API URL")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Template App")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reload") {
                    Task {
                        await viewModel.load()
                    }
                }
                .accessibilityIdentifier("reload-health-button")
            }
        }
        .task {
            guard case .idle = viewModel.state else { return }
            guard !ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return }
            await viewModel.load()
        }
    }
}

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: HealthViewModel

    init(viewModel: HealthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            HealthView(viewModel: viewModel)
        }
    }
}

@testable import TemplateApp
import XCTest

@MainActor
final class HealthViewModelTests: XCTestCase {
    func testLoadSuccessTransitionsToLoadedState() async {
        let viewModel = HealthViewModel(
            service: MockHealthAPI(result: .success(.mock)),
            logger: TestLogger())

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded(.mock))
    }

    func testLoadFailureTransitionsToFailedState() async {
        struct SampleError: LocalizedError {
            var errorDescription: String? {
                "boom"
            }
        }

        let viewModel = HealthViewModel(
            service: MockHealthAPI(result: .failure(SampleError())),
            logger: TestLogger())

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("boom"))
    }
}

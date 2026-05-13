import Foundation
import Testing
@testable import CCMeter

private final class MockFetchUsageUseCase: AsyncUseCase, @unchecked Sendable {
    var result: Result<FetchUsageResponse, Error> = .success(
        FetchUsageResponse(from: TestFixtures.makeUsage())
    )
    var executeCallCount = 0

    func execute(_ request: FetchUsageRequest) async throws -> FetchUsageResponse {
        executeCallCount += 1
        return try result.get()
    }
}

@Suite("UsageViewModel")
@MainActor
struct UsageViewModelTests {
    private let mock = MockFetchUsageUseCase()
    private var sut: UsageViewModel { UsageViewModel(fetchUsage: mock) }

    @Test("initial state has default values")
    func initialState() {
        let vm = sut

        #expect(vm.usage == nil)
        #expect(vm.errorMessage == nil)
        #expect(vm.lastUpdated == nil)
        #expect(vm.isLoading == false)
        #expect(vm.pollingInterval == .fiveMinutes)
    }

    @Test("refresh success updates usage and lastUpdated")
    func refresh_success() async {
        let vm = sut

        await vm.refresh()

        #expect(vm.usage != nil)
        #expect(vm.lastUpdated != nil)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }

    @Test("refresh success clears existing error")
    func refresh_clearsError() async {
        let vm = sut
        mock.result = .failure(DomainError.tokenNotFound)
        await vm.refresh()
        #expect(vm.errorMessage != nil)

        mock.result = .success(FetchUsageResponse(from: TestFixtures.makeUsage()))
        await vm.refresh()

        #expect(vm.errorMessage == nil)
        #expect(vm.usage != nil)
    }

    @Test("refresh failure sets errorMessage")
    func refresh_failure_setsError() async {
        let vm = sut
        mock.result = .failure(DomainError.tokenNotFound)

        await vm.refresh()

        #expect(vm.errorMessage != nil)
        #expect(vm.usage == nil)
        #expect(vm.isLoading == false)
    }

    @Test("refresh failure preserves existing usage")
    func refresh_failure_preservesUsage() async {
        let vm = sut
        await vm.refresh()
        let previousUsage = vm.usage
        #expect(previousUsage != nil)

        mock.result = .failure(DomainError.networkError("offline"))
        await vm.refresh()

        #expect(vm.usage == previousUsage)
        #expect(vm.errorMessage != nil)
    }

}

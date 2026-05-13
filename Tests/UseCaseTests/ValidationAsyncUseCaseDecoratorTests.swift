import Foundation
import Testing
@testable import CCMeter

private struct StubRequest: UseCaseRequest {
    var shouldThrow = false

    func validate() throws {
        if shouldThrow {
            throw ValidationError.invalidRequest("test validation failure")
        }
    }
}

private final class StubUseCase: AsyncUseCase, @unchecked Sendable {
    var executeCallCount = 0
    var result: Result<String, Error> = .success("ok")

    func execute(_ request: StubRequest) async throws -> String {
        executeCallCount += 1
        return try result.get()
    }
}

@Suite("ValidationAsyncUseCaseDecorator")
struct ValidationAsyncUseCaseDecoratorTests {
    private let stub = StubUseCase()

    @Test("valid request delegates to decoratee and returns result")
    func validRequest_delegates() async throws {
        let sut = ValidationAsyncUseCaseDecorator(decoratee: stub)

        let result = try await sut.execute(StubRequest(shouldThrow: false))

        #expect(result == "ok")
        #expect(stub.executeCallCount == 1)
    }

    @Test("invalid request throws before calling decoratee")
    func invalidRequest_throwsBeforeDelegate() async {
        let sut = ValidationAsyncUseCaseDecorator(decoratee: stub)

        await #expect(throws: ValidationError.self) {
            _ = try await sut.execute(StubRequest(shouldThrow: true))
        }
        #expect(stub.executeCallCount == 0)
    }

    @Test("decoratee error propagates through decorator")
    func decorateeError_propagates() async {
        stub.result = .failure(DomainError.tokenNotFound)
        let sut = ValidationAsyncUseCaseDecorator(decoratee: stub)

        await #expect(throws: DomainError.self) {
            _ = try await sut.execute(StubRequest(shouldThrow: false))
        }
    }
}

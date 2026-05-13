final class ValidationAsyncUseCaseDecorator<
    Request: UseCaseRequest,
    Response: Sendable,
    Decorated: AsyncUseCase
>: AsyncUseCase, Sendable
where Decorated.Request == Request, Decorated.Response == Response {
    private let decoratee: Decorated

    init(decoratee: Decorated) {
        self.decoratee = decoratee
    }

    func execute(_ request: Request) async throws -> Response {
        try request.validate()
        return try await decoratee.execute(request)
    }
}

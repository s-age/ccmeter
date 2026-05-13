protocol UseCaseRequest: Sendable {
    func validate() throws
}

protocol AsyncUseCase<Request, Response>: Sendable {
    associatedtype Request: UseCaseRequest
    associatedtype Response: Sendable
    func execute(_ request: Request) async throws -> Response
}

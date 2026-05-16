import Foundation

final class KeychainDataSource: KeychainDataSourceProtocol, Sendable {
    private static let serviceName = "Claude Code-credentials"

    func read() throws -> KeychainCredentialsDTO {
        let username = ProcessInfo.processInfo.environment["USER"] ?? NSUserName()

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = [
            "find-generic-password",
            "-a", username,
            "-s", Self.serviceName,
            "-w"
        ]

        let stdout = Pipe()
        process.standardOutput = stdout
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            throw DomainError.tokenNotFound
        }
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw DomainError.tokenNotFound
        }

        let output = stdout.fileHandleForReading.readDataToEndOfFile()
        return try JSONDecoder().decode(KeychainCredentialsDTO.self, from: output)
    }
}

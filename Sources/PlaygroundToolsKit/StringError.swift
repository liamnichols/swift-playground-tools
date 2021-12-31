import Foundation

public struct StringError: LocalizedError {
    public let errorDescription: String?

    public init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

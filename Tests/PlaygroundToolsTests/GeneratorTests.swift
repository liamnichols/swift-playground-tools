import XCTest
import class Foundation.Bundle

final class GeneratorTests: XCTestCase {
    func testExample() throws {
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("playground-tools")
        process.arguments = [
            "/Users/liamnichols/Desktop/Invoices.swiftpm",
            "/Users/liamnichols/Desktop/Invoices"
        ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        print(output ?? "nil")
        XCTAssertNotNil(output)
//        XCTAssertEqual(output, "Hello, world! Bar\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
    }
}

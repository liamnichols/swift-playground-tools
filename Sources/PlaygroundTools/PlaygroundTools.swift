import ArgumentParser
import Foundation
import PathKit
import PlaygroundToolsKit

@main
struct PlaygroundTools: ParsableCommand {
    static var configuration = CommandConfiguration(
       abstract: "A utility for managing Swift Playground projects",
       version: "0.0.1",
       subcommands: [GenerateXcodeProject.self],
       defaultSubcommand: GenerateXcodeProject.self
    )
}

extension PlaygroundTools {
    struct GenerateXcodeProject: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "generate-xcodeproj",
            abstract: "Generates an Xcode Project from a Swift Playgrounds App."
        )

        @Argument(
            help: "The path to the .swiftpm bundle to convert.",
            completion: .file(extensions: ["swiftpm"]),
            transform: Path.init(_:)
        )
        var appPath: Path

        @Argument(
            help: "The directory to output the generated Xcode Project.",
            completion: .directory,
            transform: Path.init(_:)
        )
        var outputPath: Path

        func validate() throws {
            if !appPath.exists || !appPath.isDirectory {
                throw StringError("A .swiftpm bundle does not exist at the given path.")
            }

            if outputPath.exists {
                throw StringError("A file or directory already exists at the specified output location.")
            }
        }

        func run() throws {
            print("⌛️ Loading App:", appPath)
            let app = try SwiftPlaygroundApp(path: appPath)

            print("⚙️  Generating Xcode Project...")
            let project = XcodeProject(path: outputPath)
            try project.generate(from: app)

            print("✅ Done:", outputPath)
        }
    }
}

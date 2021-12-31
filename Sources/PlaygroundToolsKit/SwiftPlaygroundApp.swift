import Foundation
import PathKit

public struct SwiftPlaygroundApp {
    public let path: Path
    public let sources: [Path]
    public let assetCatalog: Path
    public let package: Package

    public init(path: Path) throws {
        self.path = path
        self.sources = try Self.findSourceFiles(in: path)
        self.assetCatalog = try Self.findAssetCatalog(in: path)
        self.package = try Package(path: path + "Package.swift")
    }

    static func findSourceFiles(in path: Path) throws -> [Path] {
        let packageManifest = path + "Package.swift"
        return try path
            .recursiveChildren()
            .filter { $0.url.pathExtension == "swift" && $0 != packageManifest }
    }

    static func findAssetCatalog(in bundleLocation: Path) throws -> Path {
        guard let path = bundleLocation.glob("*.xcassets").first else {
            throw StringError("Unable to find Asset Catalog")
        }

        return path
    }
}

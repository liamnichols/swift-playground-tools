import Foundation
import PathKit

// TODO: This data model should really reflect targets as well...
public struct Package {
    public struct Dependency {
        public enum VersionRequirement {
            case exact(String)
            case range(from: String, to: String)
            case branch(String)
            case revision(String)
        }

        /// The identity of the package
        public let identity: String

        /// The URL for the remote package source
        public let url: URL

        /// The defined version requirements
        public let versionRequirement: VersionRequirement

        /// The products of the given dependency that are required by the app target
        public let products: [String]
    }

    public struct TargetDependency {
        public let package: String
        public let product: String
    }

    public let name: String
    public let deploymentTarget: String
    public let displayVersion: String
    public let bundleVersion: String
    public let iconAssetName: String
    public let accentColorAssetName: String
    public let dependencies: [Dependency]
}

protocol PackageLoader {
    static func loadPackage(at path: Path) throws -> Package
}

public extension Package {
    init(path: Path) throws {
        // Things we probably need...
        //
        // 1. Parse Package.swift
        //   - name
        //   - platforms
        //
        // 2. iOSApplication details
        //   - name
        //   - displayVersion
        //   - bundleVersion
        //   - iconAssetName
        //   - accentColorAssetName
        //   - supportedDeviceFamilies
        //   - supportedInterfaceOrientations
        //   - capabilities
        //   - additionalInfoPlistContentFilePath
        //
        // 3. Dependencies
        //   - If used, also we need to copy Package.resolved

        // Easy way to switch out how we load the details that we need...
        // I expect that we'll need something more robust later on. And if not, i'm sure it'll change in the future...
        self = try HackyV4PackageLoader.loadPackage(at: path)
    }
}

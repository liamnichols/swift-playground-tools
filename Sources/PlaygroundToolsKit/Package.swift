import Foundation
import PathKit

public struct Package {
    public let name: String
    public let deploymentTarget: String
    public let displayVersion: String
    public let bundleVersion: String
    public let iconAssetName: String
    public let accentColorAssetName: String
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

import Foundation
import PathKit

enum HackyV4PackageLoader: PackageLoader {
    static func loadPackage(at path: Path) throws -> Package {
        let packageContents = try String(contentsOf: path.url)

        // Check that the Package.swift was generated in a way that we expect...
        // TODO: Make this a little cleaner 
        if let swiftToolsVersion = try firstMatch(of: #"swift-tools-version: ([0-9].*)"#, group: 1, in: packageContents) {
            if swiftToolsVersion == "5.5" {
//                print("App was produced using a known version of Swift Plagrounds 👍")
            } else {
                print("[WARNING] Unknown swift-tools-version for this App (\(swiftToolsVersion)). Generation might fail.")
            }
        } else {
            print("[WARNING] Unknown swift-tools-version for this App. Generation might fail.")
        }

        // .iOS("15.2")
        guard let deploymentTarget = try firstMatch(of: #".iOS\("([0-9.]*)"\)"#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find deployment target in package.")
        }

        // name: "(.*)"
        guard let name = try firstMatch(of: #"name: "(.*)""#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find package name in package.")
        }

        // displayVersion: "(.*)"
        guard let displayVersion = try firstMatch(of: #"displayVersion: "(.*)""#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find display version in package.")
        }

        // bundleVersion: "(.*)"
        guard let bundleVersion = try firstMatch(of: #"bundleVersion: "(.*)""#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find bundle version in package.")
        }

        // iconAssetName: "(.*)"
        guard let iconAssetName = try firstMatch(of: #"iconAssetName: "(.*)""#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find icon asset name in package.")
        }

        // accentColorAssetName: "(.*)"
        guard let accentColorAssetName = try firstMatch(of: #"accentColorAssetName: "(.*)""#, group: 1, in: packageContents) else {
            throw LoadError(errorDescription: "Unable to find acceent color asset name in package.")
        }

        return Package(
            name: name,
            deploymentTarget: deploymentTarget,
            displayVersion: displayVersion,
            bundleVersion: bundleVersion,
            iconAssetName: iconAssetName,
            accentColorAssetName: accentColorAssetName
        )
    }

    private static func firstMatch(of pattern: String, group: Int = 0, in string: String) throws -> String? {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let entireRange = NSRange(string.startIndex ..< string.endIndex, in: string)

        guard let match = regex.firstMatch(in: string, options: [], range: entireRange) else { return nil }

        let range = match.range(at: group)
        guard let stringRange = Range(range, in: string) else { throw LoadError(errorDescription: "Range detection failed") }
        return String(string[stringRange])
    }
}

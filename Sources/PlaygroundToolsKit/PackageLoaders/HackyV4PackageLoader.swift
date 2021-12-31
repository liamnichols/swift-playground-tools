import Foundation
import PathKit
import ProjectSpec

// TODO: Clean up
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
            accentColorAssetName: accentColorAssetName,
            dependencies: try dependencies(from: packageContents)
        )
    }

    private static func dependencies(from packageContents: String) throws -> [Package.Dependency] {
        // Extract the package dependency defintions
        let packageDependencies: [(url: String, versionRequirement: String)] = try matches(
            of: #".package\(url: "(.*)", (.*)\)"#,
            in: packageContents
        ).map { (url: $0[1], versionRequirement: $0[2]) }

        // Extract the target dependnecy info
        let targetDependnecies: [(product: String, package: String)] = try matches(
            of: #".product\(name: "(.*)", package: "(.*)"\)"#,
            in: packageContents
        ).map({ (product: $0[1], package: $0[2]) })

        // Iterate the defined package dependencies and parse their values
        return try packageDependencies.map { (url, versionRequirement) in
            // A note on 'Identity'
            // See: `swift package describe` (look at the output)
            // See: https://forums.swift.org/t/urls-as-swift-package-identifiers/43404
            //
            // > the identity of a package is computed from the last path component of its effective URL
            //
            // We need to know this to figure out which target dependencies relate to which remote package.
            guard let url = URL(string: url), let identity = url.pathComponents.last?.lowercased() else {
                throw LoadError(errorDescription: "\(url) is not a valid URL")
            }

            return Package.Dependency(
                identity: identity,
                url: url,
                versionRequirement: try self.versionRequirement(from: versionRequirement),
                products: targetDependnecies
                    .filter { $0.package.lowercased() == identity }
                    .map { $0.product }
            )
        }
    }

    private static func versionRequirement(from string: String) throws -> Package.Dependency.VersionRequirement {
        if let exact = try firstMatch(of: #".exact\("(.*)"\)"#, group: 1, in: string) {
            return .exact(exact)
        }

        if let range = try matches(of: #""(.*)"\.\.<"(.*)""#, in: string).first {
            return .range(from: range[1], to: range[2])
        }

        if let branch = try firstMatch(of: #".branch\("(.*)"\)"#, group: 1, in: string) {
            return .branch(branch)
        }

        if let revision = try firstMatch(of: #".revision\("(.*)"\)"#, group: 1, in: string) {
            return .revision(revision)
        }

        throw LoadError(errorDescription: "Unknown package version requirement '\(string)'")
    }

    private static func firstMatch(of pattern: String, group: Int = 0, in string: String) throws -> String? {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let entireRange = NSRange(string.startIndex ..< string.endIndex, in: string)

        guard let match = regex.firstMatch(in: string, options: [], range: entireRange) else { return nil }

        let range = match.range(at: group)
        guard let stringRange = Range(range, in: string) else { throw LoadError(errorDescription: "Range detection failed") }
        return String(string[stringRange])
    }

    private static func matches(of pattern: String, in string: String) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let entireRange = NSRange(string.startIndex ..< string.endIndex, in: string)

        let matches = regex.matches(in: string, options: [], range: entireRange)

        return try matches.map { match in
            var strings: [String] = []
            for idx in 0 ..< match.numberOfRanges {
                let range = match.range(at: idx)
                guard let stringRange = Range(range, in: string) else { throw LoadError(errorDescription: "Range detection failed") }
                strings.append(String(string[stringRange]))
            }
            return strings
        }
    }
}

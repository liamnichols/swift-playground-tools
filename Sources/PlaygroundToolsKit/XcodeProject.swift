import Foundation
import XcodeProj
import XcodeGenKit
import ProjectSpec
import PathKit
import Version

public struct XcodeProject {
    let path: Path

    public init(path: Path) {
        self.path = path
    }

    public func generate(from app: SwiftPlaygroundApp) throws {
        guard !path.exists else {
            throw GeneratorError(errorDescription: "A project already exists in the output directory")
        }

        // Resolve some base values
        let targetName = app.package.name
        let targetPath = path + targetName
        let xcodeProjPath = path + "\(app.package.name).xcodeproj"

        // TODO: These could come from Package at some point
        let supportedInterfaceOrientationsPad = [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationPortraitUpsideDown",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ].joined(separator: " ")
        let supportedInterfaceOrientationsPhone = [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ].joined(separator: " ")

        // TODO: Create a better bundle identifier.
        // TODO: I think this needs to be read from somewhere also?
        let bundleIdentifier = "com.playground-tools.generated.\(targetName.replacingOccurrences(of: " ", with: "-"))"

        // Create the target path if it doesn't exist
        if !targetPath.exists {
            try targetPath.mkpath()
        }

        // Copy all source files
        for source in app.sources {
            let relative = try source.relativePath(from: app.path).string
            let destination = targetPath + relative

            let dir = destination.parent()
            if !dir.exists {
                try dir.mkpath()
            }

            try source.copy(destination)
        }

        // Copy Resources
        try app.assetCatalog.copy(targetPath + app.assetCatalog.url.lastPathComponent)

        // Build the Project description
        let project = Project(
            basePath: path,
            name: app.package.name,
            configs: Config.defaultConfigs,
            targets: [
                Target(
                    name: targetName,
                    type: .application,
                    platform: .iOS,
                    productName: nil,
                    deploymentTarget: Version(app.package.deploymentTarget),
                    settings: Settings(
                        buildSettings: [
                            "ASSETCATALOG_COMPILER_APPICON_NAME": app.package.iconAssetName,
                            "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": app.package.accentColorAssetName,
                            "CODE_SIGN_STYLE": "Automatic",
                            "CURRENT_PROJECT_VERSION": app.package.bundleVersion,
                            "ENABLE_PREVIEWS": "YES",
                            "GENERATE_INFOPLIST_FILE": "YES",
                            "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                            "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                            "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                            "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": supportedInterfaceOrientationsPad,
                            "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": supportedInterfaceOrientationsPhone,
                            "MARKETING_VERSION": app.package.displayVersion,
                            "PRODUCT_BUNDLE_IDENTIFIER": bundleIdentifier,
                            "PRODUCT_NAME": "$(TARGET_NAME)",
                            "SWIFT_EMIT_LOC_STRINGS": "YES",
                            "SWIFT_VERSION": "5.0",
                            "TARGETED_DEVICE_FAMILY": "1,2",
                        ],
                        configSettings: [:],
                        groups: []
                    ),
                    configFiles: [:],
                    sources: [
                        TargetSource(
                            path: try targetPath.relativePath(from: path).string,
                            name: nil,
                            group: nil,
                            compilerFlags: [],
                            excludes: [],
                            includes: [],
                            type: nil,
                            optional: false,
                            buildPhase: nil,
                            headerVisibility: nil,
                            createIntermediateGroups: nil,
                            attributes: [],
                            resourceTags: []
                        )
                    ],
                    dependencies: [],
                    info: nil, // We manage the Info.plist manually
                    entitlements: nil, // TODO: Populate from Capabilities.
                    transitivelyLinkDependencies: nil,
                    directlyEmbedCarthageDependencies: nil,
                    requiresObjCLinking: nil,
                    preBuildScripts: [],
                    postCompileScripts: [],
                    postBuildScripts: [],
                    buildRules: [],
                    scheme: nil,
                    legacy: nil,
                    attributes: [:],
                    onlyCopyFilesOnInstall: false
                )
            ],
            aggregateTargets: [],
            settings: .empty,
            settingGroups: [:],
            schemes: [],
            packages: [:], // TODO: Figure this out
            options: SpecOptions(),
            fileGroups: [],
            configFiles: [:],
            attributes: [:],
            projectReferences: []
        )

        // Generate the .xcodeproj file, write it to disk
        let xcodeProjGenerator = ProjectGenerator(project: project)
        let xcodeProj = try xcodeProjGenerator.generateXcodeProject(in: path)
        try xcodeProj.write(path: xcodeProjPath, override: false)
    }
}

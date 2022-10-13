//
//  NativeStage.swift
//  MBoxDevNative
//
//  Created by Whirlwind on 2021/6/1.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDev
import MBoxCocoapods
import MBoxRuby

public class NativeStage: BuildStage {

    public static var name: String {
        return "Native"
    }

    required public init(outputDir: String) {
        self.outputDir = outputDir
        _ = try? Self.getSwiftVersion()
    }

    public var outputDir: String

    private static var swiftVersion: String?
    @discardableResult
    public static func getSwiftVersion() throws -> String {
        if let swiftVersion = self.swiftVersion { return swiftVersion }
        let cmd = MBCMD()
        cmd.bin = "swift"
        guard cmd.exec("--version") else {
            throw RuntimeError("Could not get swift version.")
        }
        let text = cmd.outputString
        guard let matchs = try text.match(regex: "Swift version ([0-9\\.]+) ") else {
            throw RuntimeError("Parse swift version failed:\n\(text)")
        }
        swiftVersion = matchs[0][1]
        return swiftVersion!
    }

    public func buildStep(for repo: MBWorkRepo) -> [BuildStep] {
        if !repo.shouldBuildSwiftPackage { return [] }
        return [.upgrade, .updateManifest, .build]
    }

    public func update(manifest: MBPluginPackage, repo: MBWorkRepo) throws {
        if manifest.allModules.contains(where: { $0.CLI }) {
            manifest.swiftVersion = try Self.getSwiftVersion()
        }
    }

    open func build(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        if repos.isEmpty {
            UI.log(verbose: "No repo should be built.")
            return
        }
        try UI.log(verbose: "Generate Xcode Scheme") {
            try self.generateScheme(repos: repos)
        }
        try UI.log(verbose: "Perform Xcode Build") {
            let cmd = XcodeCMD()
            cmd.xcworkspace = Workspace.xcworkspacePath
            cmd.scheme = "MBoxBuild"
            cmd.configuration = "Release"
            cmd.settings = ["DSTROOT": self.outputDir,
                            "DEBUG_INFORMATION_FORMAT": "dwarf",
                            "CODE_SIGN_IDENTITY":"",
                            "CODE_SIGNING_REQUIRED": "NO",
                            "CODE_SIGN_ENTITLEMENTS": "",
                            "CODE_SIGNING_ALLOWED": "NO"
            ]
            cmd.quiet = true
            cmd.derivedDataPath = self.outputDir.appending(pathComponent: "DerivedData")
            if !cmd.build() {
                throw RuntimeError("Xcode build failed: \(Workspace.xcworkspacePath)")
            }
        }
        try UI.log(verbose: "Generate Podspec") {
            try self.generatePodspec(repos: repos)
        }
    }

    private func generateScheme(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        let script = MBoxDevNative.bundle.path(forResource: "generate_scheme", ofType: "rb")!
        try BundlerCMD.setup(workingDirectory: Workspace.rootPath)
        let cmd = BundlerCMD(workingDirectory: Workspace.rootPath)
        cmd.gemfilePath = Workspace.rootPath.appending(pathComponent: "Gemfile")
        cmd.env["WORKSPACE_PATH"] = Workspace.xcworkspacePath
        cmd.env["PROJECT_PATHS"] = repos.flatMap { (repo, _, _) -> [String] in
            return repo.manifest!.allModules.compactMap { module -> String? in
                guard module.CLI else { return nil }
                return module.path.appending(pathComponent: Self.dirName).appending(pathComponent: module.name).appending(pathExtension: "xcodeproj")
            }
        }.joined(separator: ":")
        if !cmd.exec("exec ruby \(script.quoted)") {
            throw RuntimeError("Generate scheme failed!")
        }
    }

    private func generatePodspec(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        let script = MBoxDevNative.bundle.path(forResource: "spec_ipc", ofType: "rb")!
        try self.each(repos: repos, title: "Generate Podspec") { (repo: MBWorkRepo, _, nextVersion: String) in
            for module in repo.manifest!.allModules {
                guard let specPath = module.podspec else { continue }
                let head = try repo.git!.commit()
                let cmd = BundlerCMD(workingDirectory: specPath.deletingLastPathComponent)
                cmd.gemfilePath = Workspace.rootPath.appending(pathComponent: "Gemfile")
                if let url = repo.gitURL {
                    cmd.env["SPEC_SOURCE_GIT"] = url.toGitStyle()
                    cmd.env["SPEC_HOMEPAGE"] = url.toHTTPStyle()
                }
                cmd.env["SPEC_SOURCE_COMMIT"] = head.oid.desc(length: 7)
                cmd.env["PRODUCT_DIR"] = repo.productDir(self.outputDir)
                cmd.env["SPEC_VERSION"] = nextVersion
                cmd.env["SPEC_ORIGIN_PATH"] = specPath
                cmd.env["SPEC_TARGET_PATH"] = repo.productDir(self.outputDir).appending(pathComponent: module.relativeDir).appending(pathComponent: specPath.lastPathComponent).appending(pathExtension: "json")
                cmd.exec("exec ruby \(script.quoted)")
            }
        }
    }

    public func upgrade(repo: MBWorkRepo, curVersion: String?, nextVersion: String) throws {
        try repo.updateSwiftVersion(nextVersion)
    }
}

extension NativeStage: DevTemplate {

    public static var path: String? {
        return MBoxDevNative.pluginPackage?.resoucePath(for: "Template")
    }

    public static func updateManifest(_ module: MBPluginModule) throws {
        module.CLI = true
    }

}

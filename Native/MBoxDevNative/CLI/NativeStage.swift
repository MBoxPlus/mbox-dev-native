//
//  Native.swift
//  MBoxDev
//
//  Created by Whirlwind on 2021/6/1.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDev
import MBoxCocoapods
import MBoxRuby

public class NativeStage: BuildStage {

    public static var name: String {
        return "Native"
    }

    required public init(outputDir: String) {
        self.outputDir = outputDir
    }

    public var outputDir: String

    private static var swiftVersion: String?
    public static func getSwiftVersion() throws -> String {
        if let swiftVersion = self.swiftVersion { return swiftVersion }
        let cmd = MBCMD()
        cmd.bin = "swift"
        guard cmd.exec("--version") else {
            throw RuntimeError("Could not get swift version.")
        }
        let text = cmd.outputString
        guard let matchs = try text.match("Swift version ([0-9\\.]+) ") else {
            throw RuntimeError("Parse swift version failed:\n\(text)")
        }
        swiftVersion = matchs[0][1]
        return swiftVersion!
    }

    public func update(manifest: MBPluginPackage, repo: MBWorkRepo, version: String) throws {
        if manifest.CLI == true {
            manifest.swiftVersion = try Self.getSwiftVersion()
        }
    }

    open func build(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        let shouldBuildSwift = repos.contains(where: { $0.repo.shouldBuildSwiftPackage })
        if shouldBuildSwift {
            try UI.log(verbose: "Xcode Build") {
                let cmd = XcodeCMD()
                cmd.xcworkspace = Workspace.xcworkspacePath
                cmd.scheme = "MBox"
                cmd.configuration = "Release"
                cmd.settings = ["DSTROOT": self.outputDir]
                cmd.derivedDataPath = self.outputDir.appending(pathComponent: "DerivedData")
                if !cmd.build() {
                    throw RuntimeError("Xcode build failed: \(Workspace.xcworkspacePath)")
                }
            }
            try UI.log(verbose: "Generate Podspec") {
                try self.generatePodspec(repos: repos)
            }
        } else {
            UI.log(verbose: "No repo should be built.")
        }
    }

    private func generatePodspec(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        try BundlerCMD.setup(workingDirectory: Workspace.rootPath)
        let script = MBoxDevNative.bundle.path(forResource: "spec_ipc", ofType: "rb")!
        for (repo, _, nextVersion) in repos {
            try UI.log(verbose: "[\(repo)]") {
                for specPath in repo.allPodspecPaths() {
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
                    cmd.env["SPEC_TARGET_PATH"] = repo.productDir(self.outputDir).appending(pathComponent: specPath.lastPathComponent).appending(pathExtension: "json")
                    cmd.exec("exec ruby \(script.quoted)")
                }
            }
        }
    }

    open func test(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        let shouldBuildSwift = repos.contains(where: { $0.repo.shouldBuildSwiftPackage })
        if shouldBuildSwift {
            let cmd = XcodeCMD()
            cmd.xcworkspace = Workspace.xcworkspacePath
            cmd.scheme = "MBox"
            cmd.configuration = "Release"
            cmd.settings = ["DSTROOT": self.outputDir]
            if !cmd.test() {
                throw RuntimeError("Xcode test failed: \(Workspace.xcworkspacePath)")
            }
        } else {
            UI.log(verbose: "No repo should be test.")
        }
    }

    public func shouldBuild(repo: MBWorkRepo) -> Bool {
        return repo.shouldBuildSwiftPackage
    }

    public func upgrade(repo: MBWorkRepo, nextVersion: String) throws {
        try repo.updateSwiftVersion(nextVersion)
    }
}

extension NativeStage: DevTemplate {

    public static var path: String? {
        return MBoxDevNative.pluginPackage?.resoucePath(for: "Template")
    }

    public static func updateManifest(_ manifest: MBPluginPackage) throws {
        manifest.CLI = true
    }

}

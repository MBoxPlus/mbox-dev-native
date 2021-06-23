//
//  Native.swift
//  MBoxDev
//
//  Created by 詹迟晶 on 2021/6/1.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDev
import MBoxCocoapods

public class NativeStage: BuildStage {

    public static var name: String {
        return "Native"
    }

    required public init(outputDir: String) {
        self.outputDir = outputDir
    }

    public var outputDir: String

    public static var path: String? {
        return MBoxDevNative.pluginPackage?.resoucePath(for: "Template")
    }

    public static func updateManifest(_ manifest: MBPluginPackage) {
        manifest.CLI = true
    }

    open func build(repos: [(repo: MBWorkRepo, curVersion: String?, nextVersion: String)]) throws {
        let shouldBuildSwift = repos.contains(where: { $0.repo.shouldBuildSwiftPackage })
        if shouldBuildSwift {
            let cmd = XcodeCMD()
            cmd.xcworkspace = Workspace.xcworkspacePath
            cmd.scheme = "MBox"
            cmd.configuration = "Release"
            cmd.settings = ["DSTROOT": self.outputDir]
            if !cmd.build() {
                throw RuntimeError("Xcode build failed: \(Workspace.xcworkspacePath)")
            }
        } else {
            UI.log(verbose: "No repo should be built.")
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

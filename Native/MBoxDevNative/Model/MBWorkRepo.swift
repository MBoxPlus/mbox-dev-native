//
//  MBConfig.Repo.swift
//  MBoxDev
//
//  Created by Whirlwind on 2019/11/17.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDev
import MBoxCocoapods

extension MBWorkRepo {
    // MARK: - Version
    public func updateSwiftVersion(_ version: String) throws {
        guard let modules = self.manifest?.allModules.filter({ $0.CLI }), !modules.isEmpty else { return }
        for module in modules {
            try module.updateSwiftVersion(version, repo: self)
        }
    }

    // MARK: - Build
    public var shouldBuildSwiftPackage: Bool {
        return self.manifest!.allModules.contains { $0.CLI }
    }
}

extension MBPluginModule {
    // MARK: - Version
    public func updateSwiftVersion(_ version: String, repo: MBWorkRepo) throws {
        let path = self.path.appending(pathComponent: NativeStage.dirName).appending(pathComponent: "Basic.xcconfig")
        guard path.isExists else { return }
        var content = try String(contentsOfFile: path)
        content = content.replacingOccurrences(of: "MARKETING_VERSION *=.*", with: "MARKETING_VERSION = \(version)", options: .regularExpression, range: nil)
        if !content.contains("MARKETING_VERSION") {
            content = "\nMARKETING_VERSION = \(version)\n\(content)"
        }
        try UI.log(verbose: "Update `\(path)`") {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            if let git = repo.git {
                try? git.change(file: path.relativePath(from: git.path), track: false)
            }
        }
    }
}

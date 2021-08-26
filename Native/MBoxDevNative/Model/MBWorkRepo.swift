//
//  MBConfig.Repo.swift
//  MBoxDev
//
//  Created by Whirlwind on 2019/11/17.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDev
import MBoxCocoapods

extension MBWorkRepo {
    // MARK: - Path
    public var swiftDir: String? {
        guard self.shouldBuildSwiftPackage else { return nil }
        let dir = self.path.appending(pathComponent: "Native")
        guard dir.isExists else {
            return nil
        }
        return dir
    }

    // MARK: - Version
    public func updateSwiftVersion(_ version: String) throws {
        guard let xcodeproj = self.setting.cocoapods?.xcodeproj else {
            throw RuntimeError("No find the xcodeproj path.")
        }
        var path = self.path.appending(pathComponent: xcodeproj)
        path = (path as NSString).deletingLastPathComponent.appending(pathComponent: "Basic.xcconfig")
        var content: String = ""
        if path.isExists {
            content = try String(contentsOfFile: path)
            content = content.replacingOccurrences(of: "MARKETING_VERSION *=.*", with: "MARKETING_VERSION = \(version)", options: .regularExpression, range: nil)
        }
        if !content.contains("MARKETING_VERSION") {
            content = "\nMARKETING_VERSION = \(version)\n\(content)"
        }
        try UI.log(verbose: "Update `\(path)`") {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            if let git = self.git {
                try? git.change(file: path.relativePath(from: git.path), track: false)
            }
        }
    }

    // MARK: - Build
    public var shouldBuildSwiftPackage: Bool {
        return self.manifest?.CLI == true || self.setting.cocoapods?.xcodeproj != nil
    }
}

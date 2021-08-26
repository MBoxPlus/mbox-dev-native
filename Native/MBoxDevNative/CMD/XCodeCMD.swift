//
//  XCodeCMD.swift
//  MBoxDev
//
//  Created by Whirlwind on 2019/11/17.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

open class XcodeCMD: MBCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        self.bin = "xcodebuild"
    }

    public var project: String?
    public var xcworkspace: String?
    public var scheme: String!
    public var configuration: String?
    public var quiet: Bool = true
    public var settings: [String: String]? = nil
    public var derivedDataPath: String? = nil

    open override func exec(_ string: String, workingDirectory: String? = nil, env: [String : String]? = nil) -> Int32 {
        var args = [String]()
        if let project = project {
            args.append(contentsOf: ["-project", project.quoted])
        }
        if let xcworkspace = xcworkspace {
            args.append(contentsOf: ["-workspace", xcworkspace.quoted])
        }
        args.append(contentsOf: ["-scheme", scheme.quoted])
        if let configuration = configuration {
            args.append(contentsOf: ["-configuration", configuration.quoted])
        }
        for (k, v) in settings ?? [:] {
            args.append("\(k)=\(v.quoted)")
        }
        if quiet {
            args.append("-quiet")
        } else {
            args.append("-showBuildTimingSummary")
        }
        args.append("-skipUnavailableActions")
        if let derivedDataPath = self.derivedDataPath {
            args.append("-derivedDataPath")
            args.append(derivedDataPath.quoted)
        }
        return super.exec(args.joined(separator: " ") + " " + string, workingDirectory: workingDirectory, env: env)
    }

    public func build() -> Bool {
        return self.exec("build")
    }

    public func clean() -> Bool {
        return self.exec("clean")
    }

    public func test() -> Bool {
        return self.exec("test")
    }
}

//
//  MBoxUnitTests.swift
//  __ProjectName__Tests
//
//  Created by 詹迟晶 on 2020/2/20.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import XCTest
import Nimble
import MBoxCore
import MBoxWorkspace

extension MBWorkspace {
    public struct Status: Equatable {
        let name: String
        let current: String
        let base: String?
        init(name: String, current: String, base: String? = nil) {
            self.name = name
            self.current = current
            self.base = base
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.name == rhs.name && lhs.current == rhs.current && lhs.base == rhs.base
        }

    }
    public func status() -> [Status] {
        return config.currentFeature.repos.map { Status(name: $0.name, current: try! $0.git!.currentDescribe().value, base: $0.baseBranch) }
    }
}

extension MBCommander {
    public class func exec(_ args: [String]) throws {
        let cmd = try Self.init(argv: ArgumentParser(arguments: args), session: UI)
        try cmd.performAction()
    }
}

class MBoxUnitTests: XCTestCase {

    lazy var rootPath: String = MBoxWorkspaceTests.global.temporaryDirectory.appending(pathComponent: .random(ofLength: 6))

    override func setUp() {
        UI.rootPath = self.rootPath
        try! FileManager.default.createDirectory(atPath: self.rootPath, withIntermediateDirectories: true, attributes: nil)
        FileManager.chdir(self.rootPath)
        exec(["init"])
    }

    override func tearDown() {
        try? FileManager.default.removeItem(atPath: rootPath)
    }

    func exec(_ cmd: [String], error: Error? = nil, file: FileString = #file, line: UInt = #line) {
        let cmds = ["mbox2"] + cmd + ["-v"]
        if let error = error {
            expect(try runCommander(cmds), file: file, line: line).to(throwError(error))
        } else {
            expect(try runCommander(cmds), file: file, line: line).toNot(throwError())
        }
    }

    var currentFeature: MBFeature {
        return UI.workspace!.config.currentFeature
    }

    func readLogFile() -> String {
        let logPath = UI.currentLogFilePath!
        return try! String(contentsOfFile: logPath)
    }
}

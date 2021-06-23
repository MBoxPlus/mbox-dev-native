//
//  NimblePlus.swift
//  MBoxWorkspaceTests
//
//  Created by 詹迟晶 on 2019/12/20.
//  Copyright © 2019 bytedance. All rights reserved.
//

import Foundation
import Nimble

extension Expectation where T == Bool {
    public func isTrue(description: String? = nil) {
        self.to(beTrue(), description: description)
    }
    public func isFalse(description: String? = nil) {
        self.to(beFalse(), description: description)
    }
}

extension Expectation where T == Any? {
    public func isNil(description: String? = nil) {
        self.to(beNil(), description: description)
    }
    public func isNotNil(description: String? = nil) {
        self.notTo(beNil(), description: description)
    }
}

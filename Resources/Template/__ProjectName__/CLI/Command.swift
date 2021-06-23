//
//  Command.swift
//  __ProjectName__
//
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

extension MBCommander {
    open class <#Command#>: MBCommander {

        open class override var description: String? {
            return "<#Description for Command Line#>"
        }

        open override func run() throws {
            try super.run()
            
        }
    }
}


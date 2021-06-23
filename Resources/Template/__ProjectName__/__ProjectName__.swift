//
//  __ProjectName__.swift
//  __ProjectName__
//

import Foundation
import MBoxCore

@objc(__ProjectName__)
open class __ProjectName__: NSObject, MBPluginProtocol {
    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.<#Command#>.self)
    }
}

//
//  __MBoxModuleName__.swift
//  __MBoxModuleName__
//

import Foundation
import MBoxCore

@objc(__MBoxModuleName__)
open class __MBoxModuleName__: NSObject, MBPluginProtocol {
    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.<#Command#>.self)
    }
}

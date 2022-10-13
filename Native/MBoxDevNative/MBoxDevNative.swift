//
//  MBoxDevNative.swift
//  MBoxDevNative
//

import Foundation
import MBoxCore
import MBoxDependencyManager

@objc(MBoxDevNative)
open class MBoxDevNative: NSObject, MBWorkspacePluginProtocol {

    public func enablePlugin(workspace: MBWorkspace, from version: String?) throws {
        var container = workspace.userSetting.container
        if container == nil {
            container = MBSetting.Container()
            workspace.userSetting.container = container
        }
        var value = container!.allowMultipleContainers ?? []
        var changed = false
        for item in [MBDependencyTool.Bundler, MBDependencyTool.CocoaPods] {
            if !value.contains(item.name) {
                changed = true
                value << item.name
            }
        }
        if changed {
            container?.allowMultipleContainers = value
            workspace.userSetting.save()
        }
    }

    public func disablePlugin(workspace: MBWorkspace) throws {
    }

}

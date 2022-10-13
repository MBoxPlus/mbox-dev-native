//
//  Pod.swift
//  MBoxDevNative
//
//  Created by Whirlwind on 2021/8/24.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxContainer
import MBoxCocoapods

extension MBCommander.Pod {
    @_dynamicReplacement(for: cmd)
    public var dev_native_cmd: MBCMD {
        let cmd = self.cmd
        cmd.env["MBOX_PLUGIN_PATHS"] = Dictionary(MBPluginManager.shared.allPackages.map { ($0.name, $0.path) }).toJSONString(pretty: false)
        cmd.env["MBOX_MODULE_PATHS"] = Dictionary(MBPluginManager.shared.allModules.map { ($0.name, $0.path) }).toJSONString(pretty: false)
        cmd.env["MBOX_MODULE_NATIVE_BUNDLE_PATHS"] = Dictionary(MBPluginManager.shared.allModules.compactMap { $0.CLI && $0.bundlePath != nil ? ($0.name, $0.bundlePath!.deletingLastPathComponent) : nil }).toJSONString(pretty: false)
        return cmd
    }
}

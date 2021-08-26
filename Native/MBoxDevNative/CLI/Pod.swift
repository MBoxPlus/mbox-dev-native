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
    open var dev_native_cmd: MBCMD {
        let cmd = self.cmd
        cmd.env["MBOX_PLUGIN_PATHS"] = Dictionary(uniqueKeysWithValues: MBPluginManager.shared.packages.map { ($0.name, $0.path!) }).toJSONString(pretty: false)
        cmd.env["MBOX_PLUGIN_NATIVE_BUNDLE_PATHS"] = Dictionary(uniqueKeysWithValues: MBPluginManager.shared.packages.compactMap { $0.nativeBundleDir == nil ? nil : ($0.name, $0.nativeBundleDir!) }).toJSONString(pretty: false)
        return cmd
    }
}

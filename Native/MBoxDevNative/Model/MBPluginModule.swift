//
//  MBPluginModule.swift
//  MBoxDevNative
//
//  Created by 詹迟晶 on 2021/9/29.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

var kMBPluginModulePodspecKey: UInt8 = 0
extension MBPluginModule {
    public var podspec: String? {
        return associatedObject(base: self, key: &kMBPluginModulePodspecKey) {
            FileManager.glob("\(self.path.appending(pathComponent: NativeStage.dirName))/*.podspec{.json,}")
        }
    }
}

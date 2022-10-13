//
//  Command.swift
//  MBoxDevNative
//
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDev

extension MBCommander.Plugin.Build {

    @_dynamicReplacement(for: stages)
    public class var native_stages: [BuildStage.Type] {
        var v = self.stages
        v.append(NativeStage.self)
        return v
    }

}

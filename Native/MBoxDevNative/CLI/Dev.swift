//
//  Dev.swift
//  MBoxDevNative
//
//  Created by Whirlwind on 2021/8/18.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDev

extension MBCommander.Plugin.Dev {

    @_dynamicReplacement(for: allTemplates)
    public class var native_allTemplates: [DevTemplate.Type] {
        var v = self.allTemplates
        v.append(NativeStage.self)
        return v
    }

}


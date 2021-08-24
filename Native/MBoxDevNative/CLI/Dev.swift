//
//  Dev.swift
//  MBoxDevNative
//
//  Created by 詹迟晶 on 2021/8/18.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDev

extension MBCommander.Plugin.Dev {

    @_dynamicReplacement(for: allTemplates)
    open class var native_allTemplates: [DevTemplate.Type] {
        var v = self.allTemplates
        v.append(NativeStage.self)
        return v
    }

}


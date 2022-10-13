//
//  Add.swift
//  MBoxDevNative
//
//  Created by 詹迟晶 on 2022/2/17.
//  Copyright © 2022 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace
import MBoxContainer

extension MBCommander.Add {
    @_dynamicReplacement(for: run())
    public func dev_native_run() throws {
        try self.run()
        if let containers = self.addedRepo?.workRepository?.containers {
            UI.section("Activate Containers") {
                self.config.currentFeature.activateContainers(containers)
            }
        }
    }
}

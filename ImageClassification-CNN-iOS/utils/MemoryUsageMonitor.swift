//
//  MemoryUsageMonitor.swift
//  ImageClassification-CNN-iOS
//
//  Created by 이종하 on 10/5/24.
//  Copyright © 2024 JoyLee. All rights reserved.
//

import MachO

final class MemoryUsageMonitor {
    func reportMemoryUsage() -> UInt64 {
        var usedMemory: UInt64 = 0
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            usedMemory = info.resident_size
        } else {
            print("Error with task_info(): \(kerr)")
        }

        return usedMemory
    }

    func bytesToMB(bytes: UInt64) -> String {
        return String(format: "%.2f MB", Double(bytes) / 1024.0 / 1024.0)
    }
}


//
//  CompanionTemplates_th.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/04.
//

import Foundation
import Combine

struct CompanionTemplates_th: CompanionTemplates {
    var greeting: String { "สวัสดีตอนเช้า วันนี้ฉันจะอยู่เคียงข้างคุณ" }
    var farewell: String { "ดูแลตัวเองด้วยนะ ฉันจะอยู่ตรงนี้เสมอ" }
    var emotionLabels: [String] {
        ["ความสุข", "ความเศร้า", "ความโกรธ", "ความประหลาดใจ", "ความสงบ"]
    }
}

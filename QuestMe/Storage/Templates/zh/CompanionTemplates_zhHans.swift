//
//  CompanionTemplates_zhHans.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companion的中文模板。

 ## 目的
 为中文用户提供问候语、告别语和情绪标签。
 */

import Foundation
import Combine

struct CompanionTemplates_zhHans: CompanionTemplates {
    var greeting: String { "早上好。今天我会支持你。" }
    var farewell: String { "保重。我一直在这里支持你。" }
    var emotionLabels: [String] {
        ["喜悦", "悲伤", "愤怒", "惊讶", "平静"]
    }
}

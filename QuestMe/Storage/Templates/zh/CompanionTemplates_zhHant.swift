//
//  CompanionTemplates_zhHant.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/04.
//

import Foundation
import Combine

struct CompanionTemplates_zhHant: CompanionTemplates {
    var greeting: String { "早安。今天我會支持你。" }
    var farewell: String { "保重。我一直在這裡支持你。" }
    var emotionLabels: [String] {
        ["喜悅", "悲傷", "憤怒", "驚訝", "平靜"]
    }
}

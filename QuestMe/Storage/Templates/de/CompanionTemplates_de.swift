//
//  CompanionTemplates_de.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionのドイツ語テンプレート。

 ## 目的
 ドイツ語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_de: CompanionTemplates {
    var greeting: String { "Guten Morgen. Ich bin für dich da." }
    var farewell: String { "Pass auf dich auf. Ich bin immer hier." }
    var emotionLabels: [String] {
        ["Freude", "Traurigkeit", "Wut", "Überraschung", "Ruhe"]
    }
}

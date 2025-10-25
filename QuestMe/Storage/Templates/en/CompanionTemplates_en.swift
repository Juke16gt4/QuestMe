//
//  CompanionTemplates_en.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionの英語テンプレート。

 ## 目的
 英語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_en: CompanionTemplates {
    var greeting: String { "Good morning. I'm here to support you today." }
    var farewell: String { "Take care. I'm always here when you need me." }
    var emotionLabels: [String] {
        ["Joy", "Sadness", "Anger", "Surprise", "Calm"]
    }
}

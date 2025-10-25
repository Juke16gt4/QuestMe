//
//  CompanionTemplates_ja.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionの日本語テンプレート。

 ## 目的
 日本語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_ja: CompanionTemplates {
    var greeting: String { "おはようございます。" }
    var farewell: String { "またいつでもお声がけください。" }
    var emotionLabels: [String] {
        ["喜び", "悲しみ", "怒り", "驚き", "安心"]
    }
}

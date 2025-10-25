//
//  CompanionTemplates_no.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionのノルウェー語テンプレート。

 ## 目的
 ノルウェー語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_no: CompanionTemplates {
    var greeting: String { "God morgen. Jeg støtter deg i dag." }
    var farewell: String { "Ta vare på deg selv. Jeg er alltid her." }
    var emotionLabels: [String] {
        ["Glede", "Sorg", "Sinne", "Overraskelse", "Ro"]
    }
}

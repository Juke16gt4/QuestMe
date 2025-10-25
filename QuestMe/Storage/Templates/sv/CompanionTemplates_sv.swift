//
//  CompanionTemplates_sv.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionのスウェーデン語テンプレート。

 ## 目的
 スウェーデン語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_sv: CompanionTemplates {
    var greeting: String { "God morgon. Jag är här för dig." }
    var farewell: String { "Ta hand om dig. Jag finns alltid här." }
    var emotionLabels: [String] {
        ["Glädje", "Sorg", "Ilska", "Överraskning", "Lugn"]
    }
}

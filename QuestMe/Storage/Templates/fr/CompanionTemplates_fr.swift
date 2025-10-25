//
//  CompanionTemplates_fr.swift
//  QuestMe
//
//  Created by 淳一 on 2025/09/29.
//

/**
 Companionのフランス語テンプレート。

 ## 目的
 フランス語ユーザー向けの文言・ラベル・挨拶を提供する。
 */

import Foundation
import Combine

struct CompanionTemplates_fr: CompanionTemplates {
    var greeting: String { "Bonjour. Je suis là pour vous aujourd'hui." }
    var farewell: String { "Prenez soin de vous. Je suis toujours là." }
    var emotionLabels: [String] {
        ["Joie", "Tristesse", "Colère", "Surprise", "Calme"]
    }
}

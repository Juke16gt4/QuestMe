//
//  CompanionTemplates_ar.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/04.
//

import Foundation
import Combine

struct CompanionTemplates_ar: CompanionTemplates {
    var greeting: String { "صباح الخير. سأكون هنا لدعمك اليوم." }
    var farewell: String { "اعتنِ بنفسك. أنا دائمًا هنا من أجلك." }
    var emotionLabels: [String] {
        ["فرح", "حزن", "غضب", "دهشة", "هدوء"]
    }
}

//
//  CompanionTemplates_es.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/04.
//

import Foundation
import Combine

struct CompanionTemplates_es: CompanionTemplates {
    var greeting: String { "Buenos días. Hoy estaré aquí para apoyarte." }
    var farewell: String { "Cuídate. Siempre estaré aquí para ti." }
    var emotionLabels: [String] {
        ["Alegría", "Tristeza", "Enojo", "Sorpresa", "Calma"]
    }
}

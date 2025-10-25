//
//  CompanionTemplates_pt.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/04.
//

import Foundation
import Combine

struct CompanionTemplates_pt: CompanionTemplates {
    var greeting: String { "Bom dia. Estarei aqui para te apoiar hoje." }
    var farewell: String { "Cuide-se. Estarei sempre aqui por você." }
    var emotionLabels: [String] {
        ["Alegria", "Tristeza", "Raiva", "Surpresa", "Calma"]
    }
}

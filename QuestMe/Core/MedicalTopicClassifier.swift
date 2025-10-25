//
//  MedicalTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/MedicalTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      医学分野のトピック分類。
//      - キーワードベースで一次分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - NaturalLanguage
//      - MedicalModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine
import NaturalLanguage

final class MedicalTopicClassifier: ObservableObject {
    func classify(_ text: String) -> MedicalTopic {
        let l = text.lowercased()
        if l.contains("内科") || l.contains("心臓") { return .internalMed }
        if l.contains("外科") || l.contains("手術") { return .surgery }
        if l.contains("薬") || l.contains("副作用") { return .pharmacology }
        if l.contains("公衆衛生") || l.contains("感染症") { return .publicHealth }
        if l.contains("栄養") || l.contains("食事") { return .nutrition }
        if l.contains("リハビリ") || l.contains("理学療法") { return .rehab }
        if l.contains("スポーツ") || l.contains("運動") { return .sports }
        return .other
    }
}

//
//  SpeechDrillService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SpeechDrillService.swift
//
//  🎯 ファイルの目的:
//      資格用語や例文を音声で練習。
//      - TTSと発音評価に対応可能。
//      - TOEFLなどの音声学習に活用。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct SpeechDrillItem: Identifiable {
    let id = UUID()
    let phrase: String
    let languageCode: String
}

final class SpeechDrillService: ObservableObject {
    func drills(for certification: String) -> [SpeechDrillItem] {
        if certification.lowercased().contains("toefl") {
            return [
                SpeechDrillItem(phrase: "The lecture discusses the impact of climate change.", languageCode: "en-US"),
                SpeechDrillItem(phrase: "Please summarize the speaker’s opinion.", languageCode: "en-US")
            ]
        }
        return []
    }
}

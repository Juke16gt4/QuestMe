//
//  CompanionOverlay+NarrativeML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionOverlay+NarrativeML.swift
//
//  🎯 ファイルの目的:
//      EmotionNarrativeAdvisor による ML ベースのナラティブ生成を CompanionOverlay に統合。
//      - UserSettingsManager.currentStyle を style 文字列に変換して利用。
//      - 失敗時は既存のロジックにフォールバック。
//
//  🔗 依存:
//      - Managers/Advice/EmotionNarrativeML.swift
//      - Protocols/MLAdvisor.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

extension CompanionOverlay {
    func speakNarrativeML(for entries: [AdviceFeelingEntry]) {
        guard !entries.isEmpty else {
            speak("最近の記録が見つかりませんでした。また来週、気持ちを聞かせてくださいね。", emotion: .neutral)
            return
        }
        let style = UserSettingsManager.shared.currentStyle
        let styleKey: String = {
            switch style {
            case .poetic: return "poetic"
            case .logical: return "logical"
            case .humorous: return "humorous"
            case .gentle: return "gentle"
            case .sexy: return "sexy"
            }
        }()

        let inputs = entries.map { EmotionEntryInput(dateString: String($0.date.prefix(10)), feeling: $0.feeling) }
        let advisor = EmotionNarrativeML()
        let text = advisor.narrative(for: inputs, style: styleKey)
        speak(text, emotion: .neutral)
    }
}

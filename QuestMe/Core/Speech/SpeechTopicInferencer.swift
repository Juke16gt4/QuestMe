//
//  SpeechTopicInferencer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Speech/SpeechTopicInferencer.swift
//
//  🎯 ファイルの目的:
//      発話内容からトピックを推定し、ConversationEntry に分類ラベルを付与する。
//      - 12言語対応（日本語・英語・ポルトガル語・フランス語・ドイツ語・スペイン語・中国語・韓国語・イタリア語・ヒンディー語・スウェーデン語・ノルウェー語）
//      - トピック分類は「資格-試験」「講義-進行」「感情-記録」「生活-支援」「その他-未分類」
//      - SpeechCompletionLogger.swift から呼び出される
//
//  🔗 関連/連動ファイル:
//      - SpeechCompletionLogger.swift（保存時に使用）
//      - ConversationEntry.swift（分類ラベル）
//      - SpeechSync.swift（統合ラッパー）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation

public final class SpeechTopicInferencer {
    public init() {}

    public func inferTopic(from text: String, language: String = "ja") -> String {
        let lowercased = text.lowercased()

        switch language {
        case "ja":
            if text.contains("試験") || text.contains("資格") { return "資格-試験" }
            if text.contains("講義") || text.contains("会議") { return "講義-進行" }
            if text.contains("感情") || text.contains("気持ち") { return "感情-記録" }
            if text.contains("生活") || text.contains("予定") { return "生活-支援" }
        case "en":
            if lowercased.contains("exam") || lowercased.contains("license") { return "資格-試験" }
            if lowercased.contains("lecture") || lowercased.contains("meeting") { return "講義-進行" }
            if lowercased.contains("emotion") || lowercased.contains("feeling") { return "感情-記録" }
            if lowercased.contains("life") || lowercased.contains("schedule") { return "生活-支援" }
        case "pt":
            if lowercased.contains("exame") || lowercased.contains("licença") { return "資格-試験" }
            if lowercased.contains("aula") || lowercased.contains("reunião") { return "講義-進行" }
            if lowercased.contains("emoção") || lowercased.contains("sentimento") { return "感情-記録" }
            if lowercased.contains("vida") || lowercased.contains("agenda") { return "生活-支援" }
        case "fr":
            if lowercased.contains("examen") || lowercased.contains("licence") { return "資格-試験" }
            if lowercased.contains("cours") || lowercased.contains("réunion") { return "講義-進行" }
            if lowercased.contains("émotion") || lowercased.contains("sentiment") { return "感情-記録" }
            if lowercased.contains("vie") || lowercased.contains("horaire") { return "生活-支援" }
        case "de":
            if lowercased.contains("prüfung") || lowercased.contains("lizenz") { return "資格-試験" }
            if lowercased.contains("vorlesung") || lowercased.contains("besprechung") { return "講義-進行" }
            if lowercased.contains("gefühl") || lowercased.contains("emotion") { return "感情-記録" }
            if lowercased.contains("leben") || lowercased.contains("zeitplan") { return "生活-支援" }
        case "es":
            if lowercased.contains("examen") || lowercased.contains("licencia") { return "資格-試験" }
            if lowercased.contains("clase") || lowercased.contains("reunión") { return "講義-進行" }
            if lowercased.contains("emoción") || lowercased.contains("sentimiento") { return "感情-記録" }
            if lowercased.contains("vida") || lowercased.contains("agenda") { return "生活-支援" }
        case "zh":
            if text.contains("考试") || text.contains("资格") { return "資格-試験" }
            if text.contains("讲座") || text.contains("会议") { return "講義-進行" }
            if text.contains("情绪") || text.contains("感受") { return "感情-記録" }
            if text.contains("生活") || text.contains("日程") { return "生活-支援" }
        case "ko":
            if text.contains("시험") || text.contains("자격") { return "資格-試験" }
            if text.contains("강의") || text.contains("회의") { return "講義-進行" }
            if text.contains("감정") || text.contains("느낌") { return "感情-記録" }
            if text.contains("생활") || text.contains("일정") { return "生活-支援" }
        case "it":
            if lowercased.contains("esame") || lowercased.contains("licenza") { return "資格-試験" }
            if lowercased.contains("lezione") || lowercased.contains("riunione") { return "講義-進行" }
            if lowercased.contains("emozione") || lowercased.contains("sentimento") { return "感情-記録" }
            if lowercased.contains("vita") || lowercased.contains("programma") { return "生活-支援" }
        case "hi":
            if text.contains("परीक्षा") || text.contains("लाइसेंस") { return "資格-試験" }
            if text.contains("व्याख्यान") || text.contains("बैठक") { return "講義-進行" }
            if text.contains("भावना") || text.contains("अहसास") { return "感情-記録" }
            if text.contains("जीवन") || text.contains("अनुसूची") { return "生活-支援" }
        case "sv", "no":
            if lowercased.contains("prov") || lowercased.contains("licens") { return "資格-試験" }
            if lowercased.contains("föreläsning") || lowercased.contains("möte") { return "講義-進行" }
            if lowercased.contains("känsla") || lowercased.contains("emotion") { return "感情-記録" }
            if lowercased.contains("liv") || lowercased.contains("schema") { return "生活-支援" }
        default:
            return "その他-未分類"
        }
        return "その他-未分類"
    }
}

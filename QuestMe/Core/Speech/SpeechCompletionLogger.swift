//
//  SpeechCompletionLogger.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Speech/SpeechCompletionLogger.swift
//
//  🎯 ファイルの目的:
//      音声合成の終了時に、発話内容を ConversationEntry として CalendarSyncService に保存する。
//      - トピックは SpeechTopicInferencer により推定（12言語対応）
//      - 感情は neutral（中立）で固定
//      - 削除不可の記録として保存
//
//  🔗 関連/連動ファイル:
//      - CalendarSyncService.swift（保存処理）
//      - ConversationEntry.swift（保存対象）
//      - SpeechTopicInferencer.swift（トピック推定）
//      - SpeechSync.swift（統合ラッパー）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation
import AVFoundation

public final class SpeechCompletionLogger {
    private let topicInferencer = SpeechTopicInferencer()

    public init() {}

    /// 発話終了時に保存処理を実行
    public func logCompletion(for utterance: AVSpeechUtterance, language: String = "ja") {
        let topic = topicInferencer.inferTopic(from: utterance.speechString, language: language)
        let entry = ConversationEntry(
            speaker: "companion",
            text: utterance.speechString,
            emotion: "neutral",
            topic: ConversationSubject(label: topic),
            isCommand: false,
            language: language
        )
        CalendarSyncService().save(entry: entry)
    }
}

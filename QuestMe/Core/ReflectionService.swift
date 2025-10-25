//
//  ReflectionService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ReflectionService.swift
//
//  🎯 ファイルの目的:
//      ランダム振り返り機能。
//      - 過去のユーザー発話を抽出し、経過時間と共に提示。
//      - 音声合成で読み上げ、ログに保存。
//      - 直近の振り返りメッセージを @Published で公開し、UI と同期可能にする。
//
//  🔗 依存:
//      - ConversationEntry.swift
//      - ConversationSubject.swift
//      - StorageService.swift
//      - SpeechSync.swift
//      - Foundation
//      - AVFoundation
//
//  👤 作成者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class ReflectionService: ObservableObject {
    private var storage: StorageService?
    private var speech: SpeechSync?

    // ✅ View に通知可能な Published プロパティを追加
    @Published var lastReflection: String? = nil

    func bindServices(storage: StorageService, speech: SpeechSync) {
        self.storage = storage
        self.speech = speech
    }

    func randomReflection() {
        guard let storage else { return }
        let userLogs = storage.loadAll().filter { $0.speaker == "user" }
        guard let any = userLogs.randomElement() else { return }

        let months = Calendar.current.dateComponents([.month], from: any.timestamp, to: Date()).month ?? 0
        let topicLabel = any.topic.label
        let message = "\(months)ヶ月前、あなたが『\(any.text)』について話していましたね。覚えていますか？あなたは特に\(topicLabel)に関心があるから、私の記憶に刻んでいるんです。"

        // 音声出力
        speech?.speak(message, language: "ja-JP", rate: 0.5) // ✅ Published プロパティを更新 → View に通知
        lastReflection = message
    }
}

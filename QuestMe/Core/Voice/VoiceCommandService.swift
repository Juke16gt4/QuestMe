//
//  VoiceCommandService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Voice/VoiceCommandService.swift
//
//  🎯 ファイルの目的:
//      音声認識による操作コマンドを定義・実行する。
//      - 「保存して」「削除して」「戻る」などの自然言語コマンドを解析。
//      - Companion の発話と連動し、操作結果を吹き出しで表示。
//      - 実行された操作を ConversationEntry として保存（isCommand: true）。
//      - CalendarSyncService によって分類保存され、振り返り可能。
//
//  🔗 連動ファイル:
//      - SpeechSync.swift（発話）
//      - StorageService.swift（保存・削除）
//      - CalendarSyncService.swift（自動保存）
//      - ConversationEntry.swift（操作ログ）
//
//  👤 制作者: 津村 淳一
//  📅 修正日: 2025年10月17日
//

import Foundation

final class VoiceCommandService {
    func execute(command: String, storage: StorageService, speech: SpeechSync) {
        switch command {
        case "保存して":
            let entry = ConversationEntry(
                speaker: "user",
                text: "資格関連の保存",
                emotion: "neutral",
                topic: ConversationSubject(label: "資格-保存"),
                isCommand: true // ✅ 操作ログとして分類
            )
            storage.append(entry)
            CalendarSyncService().save(entry: entry) // ✅ 自動保存
            speech.speak("保存しました。引き続き応援します！", language: "ja-JP", rate: 0.5)

        case "削除して":
            if let last = storage.loadAll().last {
                storage.conversationLog.removeAll { $0.id == last.id }

                let entry = ConversationEntry(
                    speaker: "user",
                    text: "資格関連の削除",
                    emotion: "neutral",
                    topic: ConversationSubject(label: "資格-削除"),
                    isCommand: true
                )
                storage.append(entry)
                CalendarSyncService().save(entry: entry)
                speech.speak("削除しました。必要な情報はいつでも呼び出せます。", language: "ja-JP", rate: 0.5)
            }

        case "戻る":
            let entry = ConversationEntry(
                speaker: "user",
                text: "画面を戻る操作",
                emotion: "neutral",
                topic: ConversationSubject(label: "操作-戻る"),
                isCommand: true
            )
            storage.append(entry)
            CalendarSyncService().save(entry: entry)
            speech.speak("前の画面に戻りますね。", language: "ja-JP", rate: 0.5)
            // UI側で dismiss() を呼び出す

        default:
            let entry = ConversationEntry(
                speaker: "user",
                text: "未対応の操作コマンド: \(command)",
                emotion: "neutral",
                topic: ConversationSubject(label: "操作-未対応"),
                isCommand: true
            )
            storage.append(entry)
            CalendarSyncService().save(entry: entry)
            speech.speak("すみません、その操作はまだ対応していません。", language: "ja-JP", rate: 0.5)
        }
    }
}

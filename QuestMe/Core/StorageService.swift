//
//  StorageService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/StorageService.swift
//
//  🎯 ファイルの目的:
//      会話ログや資格関連データの永続化／取得の窓口。
//      - ObservableObject として UI と同期可能にする。
//      - ConversationEntry の読み書き API を提供。
//
//  🔗 連動ファイル:
//      - ConversationEntry.swift
//      - CertificationView.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月22日
//

import Foundation
import Combine

@MainActor
final class StorageService: ObservableObject {
    @Published private(set) var conversationLog: [ConversationEntry] = []

    init(seed: Bool = true) {
        if seed {
            conversationLog = [
                ConversationEntry(
                    speaker: "user",
                    text: "薬剤師国家試験の勉強方法",
                    emotion: "neutral",
                    topic: ConversationSubject(label: "資格-医療")
                ),
                ConversationEntry(
                    speaker: "companion",
                    text: "IT資格の範囲を区切って進めよう",
                    emotion: "neutral",
                    topic: ConversationSubject(label: "資格-IT")
                ),
            ]
        }
    }

    func append(_ entry: ConversationEntry) {
        conversationLog.append(entry)
    }

    func remove(_ entry: ConversationEntry) {
        conversationLog.removeAll { $0.id == entry.id }
    }

    func loadAll() -> [ConversationEntry] {
        conversationLog
    }
}

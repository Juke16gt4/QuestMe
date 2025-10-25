//
//  CalendarSyncService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Calendar/CalendarSyncService.swift
//
//  🎯 ファイルの目的:
//      AIコンパニオンとの会話をカレンダーホルダーに自動保存する。
//      - 会話が途切れるたびに保存トリガー。
//      - ホルダーネームは「yyyyMMdd」形式（例：20252017）。
//      - ファイル名はトピックや本文から自動命名。
//      - 保存先は削除不可として保護。
//      - Companion の振り返り・予定化に活用可能。
//
//  🔗 連動ファイル:
//      - ConversationEntry.swift（保存対象）
//      - SpeechSync.swift（発話終了検知）
//      - FileManager（保存処理）
//
//  👤 制作者: 津村 淳一 
//  📅 製作日: 2025年10月17日
//

import Foundation

final class CalendarSyncService {
    private let fileManager = FileManager.default
    private let baseFolderName = "CalendarLogs"

    func save(entry: ConversationEntry) {
        let folderName = resolveFolderName(from: entry.topic.label)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStamp = dateFormatter.string(from: entry.timestamp)

        let fileName = generateFileName(from: entry.text, fallback: entry.topic.label)
        let folderURL = getDocumentsDirectory()
            .appendingPathComponent(baseFolderName)
            .appendingPathComponent(folderName)
            .appendingPathComponent(dateStamp)

        let fileURL = folderURL.appendingPathComponent("\(fileName).json")

        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
        } catch {
            print("保存失敗: \(error)")
        }
    }

    private func resolveFolderName(from topic: String) -> String {
        if topic.contains("資格") || topic.contains("試験") {
            return "専門知識・資格取得支援"
        } else if topic.contains("講義") || topic.contains("会議") {
            return "会議・講義"
        } else if topic.contains("感情") {
            return "自己理解・感情記録"
        } else if topic.contains("生活") {
            return "日常・生活支援"
        } else {
            return "未分類・その他"
        }
    }

    private func generateFileName(from text: String, fallback: String) -> String {
        let keywords = extractKeywords(from: text)
        return keywords.first ?? fallback.replacingOccurrences(of: " ", with: "_")
    }

    private func extractKeywords(from text: String) -> [String] {
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return words.filter { $0.count > 3 }.prefix(1).map { $0 }
    }

    private func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

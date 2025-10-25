//
//  ConversationLogger.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Logging/ConversationLogger.swift
//
//  🎯 ファイルの目的:
//      ユーザーとAIコンパニオンの会話内容を「おくすりアドバイス」フォルダにテキスト形式で保存。
//      - ファイル名はタイムスタンプ方式（yyyyMMdd_HHmmss.txt）
//      - 削除不可（明示的に isDeletable = false）
//      - MedicationAdviceView.swift から呼び出される
//
//  🔗 関連/連動ファイル:
//      - MedicationAdviceView.swift（会話記録）
//      - EmotionLogRepository.swift（感情ログ）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation

public final class ConversationLogger {
    public static let shared = ConversationLogger()
    private init() {}

    private let folderName = "おくすりアドバイス"

    // MARK: - 会話記録
    public func logExchange(folder: String = "おくすりアドバイス",
                            filename: String,
                            userText: String,
                            companionText: String) {
        let logText = formatLog(user: userText, companion: companionText)
        let fileURL = filePath(folder: folder, filename: filename)

        ensureFolderExists(folder: folder)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            append(text: logText, to: fileURL)
        } else {
            create(text: logText, at: fileURL)
        }
    }

    // MARK: - ログ整形
    private func formatLog(user: String, companion: String) -> String {
        let timestamp = DateFormatter.localizedTimestamp()
        var lines: [String] = []
        if !user.isEmpty {
            lines.append("[\(timestamp)] [ユーザー] \(user)")
        }
        if !companion.isEmpty {
            lines.append("[\(timestamp)] [コンパニオン] \(companion)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    // MARK: - ファイルパス生成
    private func filePath(folder: String, filename: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documents.appendingPathComponent(folder)
        return folderURL.appendingPathComponent("\(filename).txt")
    }

    // MARK: - フォルダ作成
    private func ensureFolderExists(folder: String) {
        let folderURL = filePath(folder: folder, filename: "").deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
    }

    // MARK: - ファイル作成
    private func create(text: String, at url: URL) {
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - ファイル追記
    private func append(text: String, to url: URL) {
        guard let handle = try? FileHandle(forWritingTo: url) else { return }
        handle.seekToEndOfFile()
        if let data = text.data(using: .utf8) {
            handle.write(data)
        }
        handle.closeFile()
    }
}

// MARK: - 日付フォーマッタ（拡張）

extension DateFormatter {
    public static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

    public static func localizedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: Date())
    }
}

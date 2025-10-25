//
//  MedicationEmotionLogger.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Logging/MedicationEmotionLogger.swift
//
//  🎯 目的:
//      EmotionType に準拠した感情ログ保存。
//      - Companionの発話や応答に応じて記録
//      - 削除不可ログとして保存
//

import Foundation

public final class MedicationEmotionLogger {
    public static let shared = MedicationEmotionLogger()
    private init() {}

    public func log(_ emotion: EmotionType, language: String) {
        let timestamp = DateFormatter.localizedTimestamp()
        let line = "[\(timestamp)] [\(language)] [感情] \(emotion.label) (\(emotion.rawValue))\n"
        let url = logFileURL()

        if FileManager.default.fileExists(atPath: url.path) {
            append(line, to: url)
        } else {
            create(line, at: url)
        }
    }

    private func logFileURL() -> URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent("服薬感情ログ.txt")
    }

    private func create(_ text: String, at url: URL) {
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func append(_ text: String, to url: URL) {
        guard let handle = try? FileHandle(forWritingTo: url) else { return }
        handle.seekToEndOfFile()
        if let data = text.data(using: .utf8) {
            handle.write(data)
        }
        handle.closeFile()
    }
}

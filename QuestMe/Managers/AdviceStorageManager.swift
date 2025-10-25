//
//  AdviceStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/AdviceStorageManager.swift
//
//  🎯 ファイルの目的:
//      - アドバイスデータ (Advice) の保存・読み込み・削除を管理する。
//      - JSON ファイルを介して永続化を行い、UI (CompanionAdviceView) から利用される。
//      - チームが安心してデータ操作を行えるよう、明示的で再現性のある仕組みを提供する。
//
//  🧑‍💻 作成者: 津村 淳一 (Junichi Tsumura)
//  🗓️ 製作日時: 2025-10-10 JST
//
//  🔗 依存先:
//      - Foundation（ファイル操作, Codable 利用のため）
//      - Models/Advice.swift（保存対象のデータモデル）
//      - CompanionAdviceView.swift（UI から呼び出される）
//

import Foundation

final class AdviceStorageManager {
    static let shared = AdviceStorageManager()
    private init() {}

    // 保存処理（前回のまま）
    func saveAdvice(_ text: String, type: String) {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todayFolderName = dateFormatter.string(from: today)

        let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let adviceDir = baseDir
            .appendingPathComponent("Calendar")
            .appendingPathComponent(todayFolderName)
            .appendingPathComponent("Advice")

        try? FileManager.default.createDirectory(at: adviceDir, withIntermediateDirectories: true)

        let tsFormatter = DateFormatter()
        tsFormatter.dateFormat = "yyyyMMddHHmm"
        let fileName = tsFormatter.string(from: today) + ".json"
        let fileURL = adviceDir.appendingPathComponent(fileName)

        let entry: [String: Any] = [
            "id": UUID().uuidString,
            "text": text,
            "type": type,
            "date": ISO8601DateFormatter().string(from: today)
        ]

        var logs: [[String: Any]] = []
        if let data = try? Data(contentsOf: fileURL),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            logs = existing
        }
        logs.append(entry)

        do {
            let data = try JSONSerialization.data(withJSONObject: logs, options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            print("保存失敗: \(error)")
        }
    }

    /// 指定日（yyyyMMdd）の全アドバイスを取得
    func loadAdvices(for dateString: String) -> [[String: Any]] {
        let baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let adviceDir = baseDir
            .appendingPathComponent("Calendar")
            .appendingPathComponent(dateString)
            .appendingPathComponent("Advice")

        guard let files = try? FileManager.default.contentsOfDirectory(at: adviceDir, includingPropertiesForKeys: nil) else {
            return []
        }

        var allLogs: [[String: Any]] = []
        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let logs = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                allLogs.append(contentsOf: logs)
            }
        }
        return allLogs
    }
}

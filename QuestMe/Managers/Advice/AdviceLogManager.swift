//
//  AdviceLogManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Advice/AdviceLogManager.swift
//
//  🎯 ファイルの目的:
//      - アドバイス履歴を読み込み・保存・削除する。
//      - AdviceManager との名前衝突を避けるため、AdviceLogManager に改名。
//      - CompanionAdviceView や履歴分析エンジンから呼び出される。
//      - JSON ファイルベースで永続化。
//

import Foundation

final class AdviceLogManager {
    static let shared = AdviceLogManager()

    private let fileName = "advice_log.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
    }

    func loadAll() -> [[String: Any]] {
        guard let data = try? Data(contentsOf: fileURL),
              let logs = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return logs
    }

    func save(_ entry: [String: Any]) {
        var logs = loadAll()
        logs.append(entry)
        do {
            let data = try JSONSerialization.data(withJSONObject: logs, options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            print("保存失敗: \(error)")
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}

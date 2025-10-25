//
//  LabResultStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/LabResultStorageManager.swift
//
//  🎯 ファイルの目的:
//      検査結果データの保存・読み込み・削除を管理する
//

import Foundation

final class LabResultStorageManager {
    static let shared = LabResultStorageManager()
    private let fileName = "lab_results.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(fileName)
    }

    // 保存
    func save(_ result: LabResult) {
        var results = loadAll()
        results.append(result)
        persist(results)
    }

    // 全件読み込み
    func loadAll() -> [LabResult] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        do {
            return try JSONDecoder().decode([LabResult].self, from: data)
        } catch {
            print("読み込み失敗: \(error)")
            return []
        }
    }

    // 削除
    func delete(_ result: LabResult) {
        var results = loadAll()
        results.removeAll { $0.id == result.id }
        persist(results)
    }

    // 内部保存処理
    private func persist(_ results: [LabResult]) {
        do {
            let data = try JSONEncoder().encode(results)
            try data.write(to: fileURL)
        } catch {
            print("保存失敗: \(error)")
        }
    }
}

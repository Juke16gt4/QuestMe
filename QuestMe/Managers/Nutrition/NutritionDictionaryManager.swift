//
//  NutritionDictionaryManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Nutrition/NutritionDictionaryManager.swift
//
//  🎯 目的:
//      ユーザー端末の「Library/Application Support/Nutrition」に栄養辞書を保持。
//      - 初回起動時にバンドルの NutritionDictionary.json をコピー
//      - 以後はユーザー編集・追記可能
//
//  🔗 関連/連動:
//      - NutrientDetail.swift（栄養素モデル）
//      - NutritionCameraRecordView.swift（撮影時に辞書参照）
//      - NutritionLocalSaveManager.swift（保存処理で利用）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月19日
//

import Foundation

final class NutritionDictionaryManager {
    static let shared = NutritionDictionaryManager()
    private init() {}

    private let folderName = "Nutrition"
    private let fileName = "NutritionDictionary.json"

    private func appSupportFolderURL() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent(folderName, isDirectory: true)
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private func dictFileURL() -> URL {
        appSupportFolderURL().appendingPathComponent(fileName)
    }

    func ensureDictionaryExists() {
        let fm = FileManager.default
        let dest = dictFileURL()
        guard !fm.fileExists(atPath: dest.path) else { return }

        if let src = Bundle.main.url(forResource: "NutritionDictionary", withExtension: "json") {
            try? fm.copyItem(at: src, to: dest)
        } else {
            let empty: [String: [String: NutrientDetail]] = [:]
            saveDictionary(empty)
        }
    }

    func loadDictionary() -> [String: [String: NutrientDetail]] {
        let url = dictFileURL()
        if let data = try? Data(contentsOf: url),
           let dict = try? JSONDecoder().decode([String: [String: NutrientDetail]].self, from: data) {
            return dict
        }
        return [:]
    }

    func saveDictionary(_ dict: [String: [String: NutrientDetail]]) {
        let url = dictFileURL()
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: url)
        }
    }

    func upsertIngredient(name: String, nutrients: [String: NutrientDetail]) {
        var dict = loadDictionary()
        dict[name] = nutrients
        saveDictionary(dict)
    }
}

//
//  FavoritesManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Memory/FavoritesManager.swift
//
//  🎯 ファイルの目的:
//      選択した地点名を「お気に入り」として保存・取得する（最大件数は任意、重複は折衷で許可／最新優先）。
//      - JSON に append-only で保存（削除APIも用意、必要なら拡張）。
//      - LocationInfoView から保存・一覧・選択して検索へ反映。
//      - 将来のカテゴリ別お気に入りにも拡張可能。
//
//  🔗 関連/連動ファイル:
//      - LocationInfoView.swift（保存・一覧・選択）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import Foundation

struct FavoritePlace: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let savedAt: Date
}

final class FavoritesManager {
    static let shared = FavoritesManager()

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("favorites_places.json")
    }()

    private var places: [FavoritePlace] = []

    private init() {
        load()
    }

    // MARK: - 追加
    func add(title: String) {
        let entry = FavoritePlace(id: UUID(), title: title, savedAt: Date())
        places.append(entry)
        save()
    }

    // MARK: - 取得
    func all(limit: Int? = nil) -> [FavoritePlace] {
        let sorted = places.sorted(by: { $0.savedAt > $1.savedAt })
        if let limit = limit { return Array(sorted.prefix(limit)) }
        return sorted
    }

    // MARK: - 削除（必要なら）
    func remove(id: UUID) {
        places.removeAll { $0.id == id }
        save()
    }

    // MARK: - 読み込み/保存
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            places = try JSONDecoder().decode([FavoritePlace].self, from: data)
        } catch {
            print("お気に入り読み込み失敗: \(error.localizedDescription)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(places)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("お気に入り保存失敗: \(error.localizedDescription)")
        }
    }
}

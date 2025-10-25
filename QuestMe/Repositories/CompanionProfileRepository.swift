//
//  CompanionProfileRepository.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Repositories/CompanionProfileRepository.swift
//
//  🎯 目的:
//      コンパニオンの保存・読み込み・削除・アクティブ切替（ユーザー端末内）。
//      - 高解像度画像をそのまま保存（劣化防止）。
//      - JSONベースでメタデータ管理。
//      - 12言語対応のUIに合わせた軽量API提供。
//
//  🔗 依存:
//      - Foundation, UIKit
//      - CompanionProfile.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import Foundation
import UIKit

final class CompanionProfileRepository {
    static let shared = CompanionProfileRepository()

    private let fm = FileManager.default
    private var docs: URL { fm.urls(for: .documentDirectory, in: .userDomainMask).first! }
    private var root: URL { docs.appendingPathComponent("Companions") }
    private var metaFile: URL { root.appendingPathComponent("companions.json") }
    private var activeFile: URL { root.appendingPathComponent("active.json") }

    private var cache: [CompanionProfile] = []

    init() {
        try? fm.createDirectory(at: root, withIntermediateDirectories: true)
        cache = loadAll()
    }

    func save(profile: CompanionProfile) {
        var all = loadAll().filter { $0.id != profile.id }
        all.append(profile)
        write(all)
    }

    func loadAll() -> [CompanionProfile] {
        guard fm.fileExists(atPath: metaFile.path) else { return [] }
        do {
            let data = try Data(contentsOf: metaFile)
            let all = try JSONDecoder().decode([CompanionProfile].self, from: data)
            return all
        } catch {
            return []
        }
    }

    func delete(id: UUID) {
        var all = loadAll()
        all.removeAll { $0.id == id }
        write(all)
    }

    func setActive(id: UUID) {
        let active = ["activeID": id.uuidString]
        if let data = try? JSONSerialization.data(withJSONObject: active, options: .prettyPrinted) {
            try? data.write(to: activeFile)
        }
    }

    func activeID() -> UUID? {
        guard let data = try? Data(contentsOf: activeFile),
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
              let idStr = dict["activeID"] else { return nil }
        return UUID(uuidString: idStr)
    }

    private func write(_ all: [CompanionProfile]) {
        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: metaFile)
        }
    }
}
